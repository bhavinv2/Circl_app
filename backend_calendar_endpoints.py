# Additional endpoints to add to your main.py file for calendar functionality

# Add these imports to your main.py if not already present:
# from typing import Optional
# from datetime import datetime, date

# Add these endpoints to your FastAPI app:

@app.get("/events/")
def get_events(event_date: Optional[str] = Query(None), db: Session = Depends(get_db)):
    """Get all events, optionally filtered by date"""
    query = db.query(Event)
    
    if event_date:
        try:
            # Parse the date string and filter events
            target_date = datetime.strptime(event_date, "%Y-%m-%d").date()
            query = query.filter(func.date(Event.date) == target_date)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    
    events = query.all()
    
    # Convert to response format
    return [
        {
            "id": event.id,
            "name": event.name,
            "event_type": event.event_type,
            "date": event.date.isoformat() if event.date else "",
            "points": event.points,
            "revenue": event.revenue
        }
        for event in events
    ]

@app.get("/events/upcoming")
def get_upcoming_events(days: int = Query(7), db: Session = Depends(get_db)):
    """Get upcoming events for the next X days"""
    start_date = datetime.utcnow().date()
    end_date = start_date + timedelta(days=days)
    
    events = db.query(Event).filter(
        func.date(Event.date) >= start_date,
        func.date(Event.date) <= end_date
    ).order_by(Event.date).all()
    
    return [
        {
            "id": event.id,
            "name": event.name,
            "event_type": event.event_type,
            "date": event.date.isoformat() if event.date else "",
            "points": event.points,
            "revenue": event.revenue
        }
        for event in events
    ]

@app.get("/checkins/user/{user_id}")
def get_user_checkins(user_id: int, db: Session = Depends(get_db)):
    """Get all check-ins for a specific user"""
    checkins = db.query(CheckIn).filter(CheckIn.user_id == user_id).all()
    
    return [
        {
            "id": checkin.id,
            "user_id": checkin.user_id,
            "event_id": checkin.event_id,
            "timestamp": checkin.timestamp.isoformat() if checkin.timestamp else "",
            "event_name": checkin.event.name if checkin.event else "",
            "points_earned": checkin.event.points if checkin.event else 0
        }
        for checkin in checkins
    ]

@app.get("/events/{event_id}/attendees")
def get_event_attendees(event_id: int, db: Session = Depends(get_db)):
    """Get all users who checked into a specific event"""
    checkins = db.query(CheckIn).filter(CheckIn.event_id == event_id).all()
    
    return [
        {
            "user_id": checkin.user_id,
            "name": checkin.user.name if checkin.user else "",
            "email": checkin.user.email if checkin.user else "",
            "checkin_time": checkin.timestamp.isoformat() if checkin.timestamp else ""
        }
        for checkin in checkins
    ]
