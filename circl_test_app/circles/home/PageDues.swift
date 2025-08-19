import SwiftUI
import SafariServices

struct PageDues: View {
    let circle: CircleData
    @AppStorage("user_id") private var userId: Int = 0
    @Environment(\.presentationMode) var presentationMode

    // API Configuration
    private let baseURL = "http://localhost:8000/api/"

    // State
    @State private var duesAmount: Int?
    @State private var isModerator: Bool = false
    @State private var hasStripeAccount: Bool = false

    @State private var stripeOnboardingURL: WebViewURL?
    @State private var newDuesAmount: String = ""
    @State private var isLoading = true
    @State private var checkoutURL: WebViewURL?

    // Brand
    private let brand = Color(hex: "004aad")

    var body: some View {
        ZStack {
            // Subtle brand gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    brand.opacity(0.03)
                ]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(brand)
                            .padding(10)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Circle Dues")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(circle.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if isModerator {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(brand)
                            Text("Moderator")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(brand)
                        }
<<<<<<< Updated upstream
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "004aad"))
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        if hasStripeAccount {
                            Button("Edit Stripe Info") {
                                createStripeAccount()
                            }
                            .padding(.top, 4)
                            .foregroundColor(.blue)
                        }

                    } else {
                        Button("Pay Now") {
                            startCheckout()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Dues not set yet.")
                            .foregroundColor(.secondary)

                        if isModerator {
                            if hasStripeAccount {

                                TextField("Enter dues ($)", text: $newDuesAmount)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)

                                Button("Update Dues") {
                                    updateDues()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "004aad"))
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                if hasStripeAccount {
                                    Button("Edit Stripe Info") {
                                        createStripeAccount()
                                    }
                                    .padding(.top, 4)
                                    .foregroundColor(.blue)
                                }

                            } else {
                                VStack(spacing: 12) {
                                    Button("Set Up Stripe") {
                                        createStripeAccount()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "004aad"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    
                                    Button("Refresh Status") {
                                        fetchDues()
                                    }
                                    .foregroundColor(Color(hex: "004aad"))
                                    .font(.caption)
                                }
                            }
                        } else {
                            Text("Waiting for dues setup by moderators.")
                                .foregroundColor(.secondary)
                        }

=======
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(brand.opacity(0.1)))
                        .overlay(Capsule().stroke(brand.opacity(0.15), lineWidth: 1))
>>>>>>> Stashed changes
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if isLoading {
                            // Loading card
                            LoadingCard()
                        } else {
                            // Summary card
                            DuesSummaryCard(duesAmount: duesAmount, hasStripe: hasStripeAccount)

                            // Actions / Forms
                            if let _ = duesAmount {
                                if isModerator {
                                    VStack(spacing: 12) {
                                        LabeledTextField(title: "Update dues ($)", placeholder: "e.g. 9.99", text: $newDuesAmount)
                                            .keyboardType(.decimalPad)

                                        PrimaryButton(title: "Update Dues", icon: "arrow.triangle.2.circlepath") {
                                            updateDues()
                                        }

                                        if hasStripeAccount {
                                            LinkButton(title: "Edit Stripe Info") {
                                                createStripeAccount()
                                            }
                                        }
                                    }
                                    .cardStyle()
                                } else {
                                    VStack(spacing: 12) {
                                        PrimaryButton(title: "Pay Now", icon: "creditcard.fill") {
                                            startCheckout()
                                        }
                                    }
                                    .cardStyle()
                                }
                            } else {
                                // No dues yet
                                if isModerator {
                                    if hasStripeAccount {
                                        VStack(spacing: 12) {
                                            LabeledTextField(title: "Enter dues ($)", placeholder: "e.g. 9.99", text: $newDuesAmount)
                                                .keyboardType(.decimalPad)

                                            PrimaryButton(title: "Set Dues", icon: "checkmark.circle.fill") {
                                                updateDues()
                                            }

                                            LinkButton(title: "Edit Stripe Info") {
                                                createStripeAccount()
                                            }
                                        }
                                        .cardStyle()
                                    } else {
                                        VStack(spacing: 8) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text("Stripe setup required to collect dues")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                            }

                                            PrimaryButton(title: "Set Up Stripe", icon: "link.circle.fill") {
                                                createStripeAccount()
                                            }
                                        }
                                        .cardStyle()
                                    }
                                } else {
                                    InfoNote(text: "Waiting for dues setup by moderators.")
                                        .cardStyle()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .dismissKeyboardOnScroll()
            }
<<<<<<< Updated upstream

            Spacer()
        }
        .padding()
        .onAppear {
            // Initialize from circle data first
            print("🔄 PageDues onAppear - initializing from circle data:")
            print("   - circle.isModerator: \(circle.isModerator)")
            print("   - circle.duesAmount: \(circle.duesAmount ?? -1)")
            print("   - circle.hasStripeAccount: \(circle.hasStripeAccount ?? false)")
            
            self.isModerator = circle.isModerator
            self.duesAmount = circle.duesAmount
            self.hasStripeAccount = circle.hasStripeAccount ?? false
            
            print("🔄 State after initialization:")
            print("   - isModerator: \(self.isModerator)")
            print("   - duesAmount: \(self.duesAmount ?? -1)")
            print("   - hasStripeAccount: \(self.hasStripeAccount)")
            
            // Then fetch latest data from API
            fetchDues()
=======
>>>>>>> Stashed changes
        }
        .onAppear { fetchDues() }
        .sheet(item: $stripeOnboardingURL) { wrapper in
            SafariView(url: wrapper.url)
                .onDisappear {
                    // Refresh data when returning from Stripe setup
                    print("🔄 Returned from Stripe setup - refreshing data")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        fetchDues()
                    }
                }
        }
        .sheet(item: $checkoutURL) { wrapper in
            SafariView(url: wrapper.url)
        }
    }

    // MARK: - Backend Calls

    func fetchDues() {
        print("🔄 Fetching dues for circle \(circle.id) and user \(userId)")
        guard let url = URL(string: "\(baseURL)circles/get_circle_details/?circle_id=\(circle.id)&user_id=\(userId)") else { 
            print("❌ Invalid URL for fetchDues")
            return 
        }
        
        print("🌐 Fetching dues from: \(url)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error fetching dues: \(error.localizedDescription)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Dues response status: \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data else { 
                print("❌ No data received for dues")
                return 
            }

            print("📥 Dues raw response: \(String(data: data, encoding: .utf8) ?? "nil")")

            if let decoded = try? JSONDecoder().decode(CircleData.self, from: data) {
                print("✅ Successfully decoded dues data:")
                print("   - duesAmount: \(decoded.duesAmount ?? -1)")
                print("   - isModerator: \(decoded.isModerator)")
                print("   - hasStripeAccount: \(decoded.hasStripeAccount ?? false)")

                DispatchQueue.main.async {
                    self.duesAmount = decoded.duesAmount
                    self.isModerator = decoded.isModerator
                    self.hasStripeAccount = decoded.hasStripeAccount ?? false
                }
            } else {
                print("❌ Failed to decode dues data")
                // Let's try to see what the decoding error is
                do {
                    let _ = try JSONDecoder().decode(CircleData.self, from: data)
                } catch {
                    print("🔍 Dues decoding error details: \(error)")
                }
            }

        }.resume()
    }
    private func createStripeAccount(completion: @escaping (Bool) -> Void = { _ in }) {
        print("🔄 Creating Stripe account for circle \(circle.id) and user \(userId)")
        guard let url = URL(string: "\(baseURL)circles/create_stripe_account/") else {
            print("❌ Invalid URL for createStripeAccount")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id
        ]

        print("🌐 Sending Stripe request to: \(url)")
        print("📤 Payload: \(payload)")

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error creating Stripe account: \(error.localizedDescription)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Stripe response status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received from Stripe creation")
                completion(false)
                return
            }
            
            print("📥 Stripe raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse Stripe response as JSON")
                completion(false)
                return
            }

            print("📋 Parsed Stripe response: \(json)")

            DispatchQueue.main.async {
                if let urlString = json["url"] as? String,
                   let url = URL(string: urlString) {
                    print("✅ Got Stripe onboarding URL: \(urlString)")
                    self.stripeOnboardingURL = WebViewURL(url: url)
                    completion(true)
                } else if json["status"] as? String == "already_connected" {
                    print("✅ Already connected to Stripe - updating local state")
                    self.hasStripeAccount = true
                    completion(true)
                } else {
                    print("❌ Unexpected Stripe response format")
                    completion(false)
                }
            }
        }.resume()
    }


    private func updateDues(completion: @escaping (Bool) -> Void = { _ in }) {
        let cents = Int((Double(newDuesAmount) ?? 0) * 100)

        guard let url = URL(string: "\(baseURL)circles/set_circle_dues/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "user_id": userId,
            "circle_id": circle.id,
            "price_cents": cents
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            fetchDues()
            completion(true)
        }.resume()
    }

    private func startCheckout(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let url = URL(string: "\(baseURL)circles/create_checkout_session/") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "circle_id": circle.id,
            "user_id": userId
        ])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["checkout_url"] as? String,
                  let url = URL(string: urlString) else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                self.checkoutURL = WebViewURL(url: url)
                completion(true)
            }
        }.resume()
    }
}

// MARK: - Safari WebView Wrapper

struct WebViewURL: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Local UI helpers

private struct DuesSummaryCard: View {
    let duesAmount: Int?
    let hasStripe: Bool
    private let brand = Color(hex: "004aad")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Current Dues")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                if let cents = duesAmount {
                    Text("$\(Double(cents) / 100, specifier: "%.2f")")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(brand)
                } else {
                    Text("Not set")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 8) {
                StatusPill(text: hasStripe ? "Stripe Connected" : "Stripe Not Connected", color: hasStripe ? .green : .orange)
                if duesAmount != nil {
                    StatusPill(text: "Active", color: brand)
                } else {
                    StatusPill(text: "Setup Pending", color: .orange)
                }
                Spacer()
            }
        }
        .cardStyle()
    }
}

private struct StatusPill: View {
    let text: String
    let color: Color
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.08)))
        .overlay(Capsule().stroke(color.opacity(0.15), lineWidth: 1))
    }
}

private struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

private struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    private let brand = Color(hex: "004aad")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 15, weight: .semibold)) }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [brand, Color(hex: "0066dd")]),
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: brand.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct LinkButton: View {
    let title: String
    let action: () -> Void
    private let brand = Color(hex: "004aad")

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(brand)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct LoadingCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView("Loading dues info...")
        }
        .cardStyle()
        .redacted(reason: .placeholder)
    }
}

private struct InfoNote: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.secondary)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "004aad").opacity(0.08), lineWidth: 1)
            )
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
