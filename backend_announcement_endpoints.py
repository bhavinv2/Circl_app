# Additional endpoints to add to your main.py for announcement functionality

# Add these imports to your main.py if not already present:
# from typing import Optional, List
# from datetime import datetime

# Add these endpoints to your FastAPI app:

@app.get("/api/circles/get_announcements/{circle_id}/")
def get_announcements(circle_id: int, db: Session = Depends(get_db)):
    """Get all announcements for a specific circle"""
    try:
        # This would need to be adapted based on your actual database schema
        # For now, this is a placeholder that matches your models.py structure
        announcements = db.query(Announcements).filter(
            Announcements.circle_id == circle_id  # You might need to add circle_id to your model
        ).order_by(Announcements.announced_at.desc()).all()
        
        return [
            {
                "id": announcement.id,
                "user": announcement.user.username if announcement.user else "Unknown",
                "title": announcement.title,
                "content": announcement.content,
                "announced_at": announcement.announced_at.isoformat() if announcement.announced_at else ""
            }
            for announcement in announcements
        ]
    except Exception as e:
        print(f"Error fetching announcements: {e}")
        return []

@app.post("/api/circles/create_announcement/")
def create_announcement(
    user_id: int,
    circle_id: int,
    title: str,
    content: str,
    db: Session = Depends(get_db)
):
    """Create a new announcement for a circle"""
    try:
        # Get the user
        user = db.query(UserInfo).filter(UserInfo.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Create the announcement
        announcement = Announcements(
            user=user,
            title=title,
            content=content,
            # circle_id=circle_id  # You might need to add this field to your model
        )
        
        db.add(announcement)
        db.commit()
        db.refresh(announcement)
        
        return {
            "message": "Announcement created successfully",
            "announcement_id": announcement.id
        }
        
    except Exception as e:
        db.rollback()
        print(f"Error creating announcement: {e}")
        raise HTTPException(status_code=500, detail="Failed to create announcement")

# Note: You may need to modify your Announcements model in models.py to include:
# circle_id = models.IntegerField()  # To associate announcements with specific circles

# Updated Announcements model suggestion:
"""
class Announcements(models.Model):
    user = models.ForeignKey(UserInfo, on_delete=models.CASCADE, related_name='announcements')
    circle_id = models.IntegerField()  # Add this field
    title = models.CharField(max_length=255)
    content = models.TextField()
    announced_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Announcement: {self.user.username} - {self.title}"
"""
