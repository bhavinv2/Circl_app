Receipt: I will produce a precise, file-by-file implementation plan describing exact edits (no files changed).

Checklist
1. Backend changes (models, views, new sender, tasks) with exact symbols to modify.  
2. Client changes (iOS) with exact functions to edit and behavior to add.  
3. DB/migrations and new models to add.  
4. APNs payload contract examples (per event).  
5. Testing, rollout, and verification steps.  

## Plan: Exact file-by-file edits (detailed)

TL;DR — Make the backend token registration authenticated and richer, centralize APNs sending into a single sender module, add scheduled jobs for reminders and midnight summaries (per-user local midnight), and update the iOS client to send authenticated token metadata and to handle push taps and silent pushes. Below are the exact files, the symbols to change/add, and precise behavioral instructions for each change.

Important: I will not modify files here; this is an implementation plan you or I can follow. Confirm if you want me to generate literal patch/diff text after you review this plan.

### Backend edits (Django)

1) File: `circl-backend/notifications/models.py`  
- Change: extend `DeviceToken` and keep `Notification` tracking.  
- Exact additions (describe fields to add):  
  - Add `device_id: CharField(max_length=255, null=True, blank=True)`  
  - Add `platform: CharField(max_length=32, default="ios")`  
  - Add `app_version: CharField(max_length=50, null=True, blank=True)`  
  - Add `locale: CharField(max_length=32, null=True, blank=True)`  
  - Add `last_seen: DateTimeField(auto_now=True)`  
  - Add `is_active: BooleanField(default=True)`  
- Keep `token` as unique and `user` FK.  
- Add new model `SentNotification` (namespace `notifications.models`) with fields:  
  - `user: ForeignKey(UserInfo, on_delete=CASCADE)`  
  - `notification_type: CharField(max_length=64)`  
  - `payload: JSONField()`  
  - `reference_id: IntegerField(null=True, blank=True)`  — optional event/message id  
  - `sent_at: DateTimeField(auto_now_add=True)`  
- Action: run `makemigrations` / `migrate` after adding fields.

2) File: `circl-backend/notifications/views.py` (symbol: `register_token`)  
- Change: convert from the current csrf_exempt raw JSON view to an authenticated endpoint.  
- Exact behavior to implement:  
  - Replace current `register_token` with a DRF view decorated with `@api_view(['POST'])`, `@authentication_classes([TokenAuthentication])`, `@permission_classes([IsAuthenticated])`.  
  - Extract JSON payload fields: `token` (required), optional `device_id`, `platform`, `app_version`, `locale`, `is_production` (default False).  
  - Use `request.user` as the user; do not accept or trust a `user_id` form field except to validate if present (log but ignore).  
  - Call `DeviceToken.objects.update_or_create(token=token, defaults={ "user": request.user, "device_id": device_id, "platform": platform, "app_version": app_version, "locale": locale, "is_production": is_production, "is_active": True })`.  
  - Return 201 or appropriate error status on failure.  
- Note: Keep backwards-compatible URL `/notifications/register-token/` so current clients continue to work while they are updated to include Authorization header.

3) New file: `circl-backend/notifications/sender.py` (new module)  
- Add public function: `send_apns_push(token: str, aps: dict, custom: dict = None, use_prod: bool = True) -> dict`  
- Exact responsibilities:  
  - Build outgoing JSON: merge `aps` and `custom` (top-level keys like `type` and `payload`) into a single JSON body.  
  - Use the existing certificate path pattern for now (wrap curl invocation used previously). Example behavior (no code here): run an HTTP/2 request to `https://api.push.apple.com/3/device/{token}` with the certificate for production/sandbox as selected by `use_prod`. Ensure `apns-topic: com.fragne.circl` header is set.  
  - Parse APNs response; return a result dict including `{ "status_code": int, "stdout": str, "stderr": str }`.  
  - On token error (HTTP 410 or responses that indicate invalid token), mark DeviceToken.is_active = False (import DeviceToken model and update).  
  - Log result to a central logger and optionally write a `SentNotification` record if `custom` includes `notification_type` and `user`.  
- Rationale: centralize all APNs interactions, support consistent logging and token pruning.

4) File edits: replace ad-hoc curl calls to use `notifications.sender.send_apns_push`  
- Locations to change:  
  - `circl-backend/users/views.py` — there is currently a `send_push_notification(token, title, body)` function at bottom. Replace or refactor it to call `notifications.sender.send_apns_push` and accept structured payloads; if you prefer to keep a small wrapper, have it call the new sender module.  
    - Ensure the wrapper composes `aps` = `{ "alert": {"title": title, "body": body}, "sound": "default" }` and sends extra `custom = { "type": "<type>", "payload": {...} }` as appropriate.  
  - `circl-backend/notifications/admin.py` — replace the inline `curl` loop with calls to `notifications.sender.send_apns_push` for each token and handle returned results; mark `Notification.sent = True` only after successful send attempts or after queue scheduling.  
  - `circl-backend/circles/views.py` — in `send_message` already calling `send_push_notification` — update so this call uses the centralized sender interface; pass `type: "message"` and payload containing `message_id`, `channel_id`, `circle_id`, `sender_id`, `excerpt`.  
- Exact symbol changes: rename in-place `send_push_notification` to call sender, or change imports where used: `from notifications.sender import send_apns_push` and call `send_apns_push(token, aps, custom)`.

5) File: `circl-backend/notifications/tasks.py` (new)  
- Add scheduled tasks; two main tasks:  
  - `task_send_event_reminders()` — runs every minute:  
    - Query events with start_time within window(s) for 60 minutes and 30 minutes out (use UTC comparison with user timezone conversion). For each event, for each attendee (or circle members if event is public to circle), find DeviceToken entries matching user and is_active=True and is_production appropriately; construct `aps` and `payload` and enqueue push via `send_apns_push` or schedule via a background job queue to do the actual fanout.  
    - Ensure `SentNotification` records are created to avoid double-sends.  
  - `task_send_midnight_summaries()` — runs every minute:  
    - For each user, compute user's local date/time by user.timezone (store timezone on user profile or derive from locale and device settings). If local time is within the scheduled midnight check window and no summary has been sent for "tomorrow" yet, collect tomorrow's events, build a compact summary string and payload list, then send a push of `type: "events_tomorrow_summary"`.  
- Implementation notes:  
  - Use Celery + Celery Beat if available; otherwise provide a Django management command scheduled by cron that runs every minute.  
  - Task logic:  
    - For event reminders: select events with start_time between now+30m and now+31m (for 30-min) and now+60m..61m (for 1-hour), and that have not yet had reminders sent. Create Notification DB record and send push to attendees/device tokens (exclude device tokens for the event creator if they are the attendee but are the actor).  
    - For midnight summary: per user, fetch events for user whose start_time falls on "tomorrow" in the user's timezone, build a compact summary string and payload list, then send a push of `type: "events_tomorrow_summary"`.  
  - Persist scheduled-notification records to prevent duplicates: create a `SentNotification`/`Notification` entry with fields `user`, `event`, `type`, `sent_at`. Update `DeviceToken` pruning on APNs feedback.  
- Why: supports Option A (per-user local midnight) and reliable delivery via job queue.

6) DB migration: create migrations for new fields and `SentNotification` model  
- Steps:  
  - `python manage.py makemigrations notifications`  
  - `python manage.py migrate`  
- Ensure existing `DeviceToken` rows are preserved and the new columns default sensibly.

7) Backend endpoints to ensure push triggers  
- Files and symbols to review and adapt (they already call push wrapper in places):  
  - `circl-backend/users/views.py`:  
    - `send_friend_request` — current behavior sends a push to receiver. Update to use payload:  
      - custom: `{ "type": "connection_request", "payload": { "request_id": <id>, "sender_id": <id>, "sender_name": "<name>" } }`  
    - `accept_friend_request` — sends to sender: `{ "type": "connection_accepted", payload: { "accepter_id": <id>, "accepter_name": "<name>" } }`  
    - `send_message` (private message) — send push to receiver with `type: "message"`, include `message_id`, `sender_id`, `excerpt`.  
  - `circl-backend/circles/views.py`:  
    - `send_message` (channel) — for each recipient (exclude sender), send `type: "message"` with `thread-id` header and payload.  
    - Announcement creation endpoint (search views for announcement create) — send `type: "announcement"` with `announcement_id`, `circle_id`, `title`, `excerpt`.  
- Fanout rule: use job queue when number of recipients > threshold (e.g., 25) to avoid slow request timeouts.

### Client edits (iOS Swift)

1) File: `circl_test_app/Notifications/PushNotifications/PushNotificationManager.swift`  
- Symbols to edit/add:  
  - `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` — keep token hex conversion but change storage/behavior:  
    - Store token in `UserDefaults.standard.set(token, forKey: "pending_push_token")` as currently done.  
    - If user logged in (UserDefaults user_id or better saved auth token exists), call `sendDeviceTokenToBackend(token:)` immediately.  
  - `sendDeviceTokenToBackend(token:)` (global function in file)  
    - Change behavior to:  
      - Build JSON payload with fields: `token`, `device_id` (UIDevice.current.identifierForVendor?.uuidString), `platform`: "ios", `app_version`: Bundle.main.infoDictionary?["CFBundleShortVersionString"], `locale`: Locale.current.identifier, `is_production`: true/false (determine via build config or Info.plist), optionally `is_sandbox`.  
      - Add HTTP header `Authorization` with stored auth token. Where to read auth token: use the app's auth storage (e.g., `UserDefaults.standard.string(forKey: "auth_token")`). If your app uses a different storage, replace accordingly.  
      - Set `Content-Type: application/json`.  
      - Use URLSession as current code does; on success (2xx) mark token as registered (remove pending push token key or set `push_token_registered=true`) — persist server response if desired.  
      - On error, schedule a retry (exponential backoff) or leave in `pending_push_token` for next app launch/login.  
  - Add `userNotificationCenter(_:didReceive:withCompletionHandler:)` method:  
    - Parse `notification.request.content.userInfo` to extract `type` (string) and `payload` (dictionary).  
    - If app is launched from closed state via tap, route to deep-link behavior:  
      - For `type == "message"`: call NavigationManager to open channel screen for `payload.channel_id` and `payload.circle_id`.  
      - For `type == "connection_request"`: open connections/requests UI.  
      - For `type == "connection_accepted"`: open that user's profile or a small connection confirmation.  
      - For `type == "announcement"`: open circle announcements.  
      - For `type == "event_reminder"` or `events_tomorrow_summary`: open calendar or event detail.  
    - Use same routing code paths as existing `NotificationOverlay` taps (e.g., call `NotificationCenter.default.post` with a specific notification name or call a `NavigationManager` function).  
    - Call the completion handler when finished.  
  - Add `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`:  
    - Handle `content-available:1` silent pushes: read `type` and `payload` from `userInfo`; for `message` type pull new messages (call `get_messages` or fetch message detail) and update local cache/UI; call completion handler with `.newData` or `.noData`.  
    - For other silent pushes (e.g., event update), refresh relevant data.  
  - Ensure `UNUserNotificationCenter.current().delegate = self` remains set in `didFinishLaunching`.  
- Note: do not put full message bodies in payload except short excerpt.

2) File: `circl_test_app/InAppNotifications/NotificationManager.swift`  
- Add a method: `func handlePushPayload(type: String, payload: [String: Any])`:  
  - Behavior: dedupe by `payload["message_id"]` if present before creating `InAppNotification`.  
  - For `message` type: create an `InAppNotification` with `type: .message`, set `messageId`, `channelId`, `circleId`, `senderName`, `excerpt`, then call the existing display flow so foreground and background flows share the same UI code.  
  - For other types: create appropriate `InAppNotification` entries and call display.  
- Reuse existing dedupe set (messageIdsShown) to avoid duplicate banners if app receives both a push and the polling service picks up the message.

3) Files: `circl_test_app/Onboarding/Page1.swift` and `Page19.swift`  
- Ensure calls to `sendDeviceTokenToBackend(token:)` include Authorization if the login flow just completed — confirm these call sites read the stored auth token before calling the function. If they call the global function that reads `UserDefaults` for auth token, no change needed except validation.

4) Optional: Notification Service Extension target  
- Add new iOS target "CirclNotificationService" with a `NotificationService.swift` that can:  
  - Inspect incoming notification payloads with `mutable-content = 1` and fetch remote images or attachments, attach them to the notification content, then call the content handler.  
- Only add if you need images or to mutate text; otherwise skip.

5) Local scheduling fallback (client) — file(s): event creation code (search where events are created; add scheduling in that handler)  
- When an event is created or RSVP happens, schedule 2 local UNNotifications (1 hour, 30 minutes prior) using `UNCalendarNotificationTrigger` based on the event's local date/time.

### APNs payload contract (exact keys and required behavior)

General structure (APNs JSON body, top-level):  
- aps: { alert: { title: "<title>", body: "<body>" }, sound: "default", badge: optional int, "thread-id": optional string, "mutable-content": 1 optional, "content-available": 1 optional }  
- type: string (semantic type, e.g., "message", "connection_request", "connection_accepted", "announcement", "event_reminder", "events_tomorrow_summary")  
- payload: JSON object with minimal identifiers (no PII). Examples follow:

1) Connection request
- type = "connection_request"  
- payload = { request_id: INT, sender_id: INT, sender_name: STRING }

2) Connection accepted
- type = "connection_accepted"  
- payload = { accepter_id: INT, accepter_name: STRING }

3) Circle chat message
- type = "message"  
- aps.thread-id = "circle-{circle_id}-channel-{channel_id}"  
- payload = { message_id: INT, channel_id: INT, circle_id: INT, sender_id: INT, sender_name: STRING, excerpt: STRING }

4) Announcement
- type = "announcement"  
- payload = { announcement_id: INT, circle_id: INT, title: STRING, excerpt: STRING }

5) Event reminder
- type = "event_reminder"  
- payload = { event_id: INT, circle_id: INT, title: STRING, start_time: ISO8601 UTC STRING }

6) Midnight summary
- type = "events_tomorrow_summary"  
- payload = { events: [ { id: INT, title: STRING, time_local: "HH:MM" }, ... ] }

Operational notes:  
- Use `content-available:1` only for silent background updates (app fetches details). Use sparingly to avoid iOS throttling.  
- Use `thread-id` to group chat notifications on iOS.

### Testing and verification (exact steps)

1) Backend tests:  
- Unit test for `notifications.sender.send_apns_push` that simulates APNs responses (success and invalid token) and asserts DeviceToken.is_active toggles on invalid responses.  
- Integration test for `register_token` that POSTs with Authorization header: assert DeviceToken created and linked to request.user and metadata set.  
- Integration test for `send_message` (channel) that checks `send_apns_push` called for recipient tokens (use mocking).

2) Manual end-to-end:  
- Stage app build with sandbox certificate and use test device token.  
- Call `POST /notifications/register-token/` with Authorization header and device metadata; verify DB shows DeviceToken with user and device metadata.  
- Use admin `notifications.admin` action in staging to send a test Notification (existing admin uses curl) — confirm device receives push.  
- Use crafted APNs JSON messages for each event type to verify client routing (foreground, background, cold start). Confirm `userNotificationCenter(_:didReceive:...)` opens expected screen.  
- Test silent pushes (`content-available=1`) and ensure `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` executes and fetches new data.  
- Test scheduled tasks:  
  - Create events in staging with start times 1 hour and 30 minutes out; run task runner manually and verify push sends once per event and SentNotification records created.  
  - For midnight summary, set user timezone to something close to current time for fast test (e.g., create a test user with timezone offset such that midnight is near now) and run the midnight task manually to verify summary push.

3) Rollout steps:  
- Deploy sender and register-token changes to staging first. Do not update client until server is ready to accept authenticated registration (server keeps accepting old unauthenticated payloads temporarily).  
- Release client update that sends Authorization header and richer metadata; monitor DB to see how many tokens get associated to users.  
- Deploy scheduled tasks worker to staging; test with controlled users.  
- Gradual production rollout with monitoring for APNs errors and token pruning.

### Implementation constraints & small notes
- Timezone: Option A chosen — per-user local midnight. Ensure user profiles hold timezone or derive it on first app launch and persist in `UserInfo` (field `timezone`).  
- Security: require `Authorization` header on register-token endpoint (Token auth or JWT depending on project). Do not accept user_id in request body as the authoritative source.  
- Performance: for large circles, use a background job queue (Celery/RQ/etc.) for fanout. Synchronous loops in HTTP handlers will time out and produce poor UX.

---

Next step options (pick one)  
- If you want literal patch/diff text I can prepare: say "generate patches" and I will produce per-file patch text for each change (ready for apply).  
- If you want prioritized implementation checklist instead of raw patches, say "prioritize".  

Which should I prepare next?