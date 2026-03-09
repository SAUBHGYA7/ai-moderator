import requests
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from database import get_db
from models import MessageDB

router = APIRouter()

# URL of your moderator service
MODERATOR_URL = "http://127.0.0.1:8001/api/chat/send"


class SendMessage(BaseModel):
    user_id: int
    channel_id: int
    community_id: int
    message_text: str


@router.post("/send")
def send_message(data: SendMessage, db: Session = Depends(get_db)):

    try:

        # Send message to AI moderator
        response = requests.post(
            MODERATOR_URL,
            json={
                "user_id": data.user_id,
                "group_id": data.community_id,
                "message": data.message_text
            }
        )

        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Moderator service failed")

        result = response.json()

        status = result.get("action", "FLAGGED")
        feedback = result.get("feedback")

        # Store message in database
        message = MessageDB(
            user_id=data.user_id,
            channel_id=data.channel_id,
            message_text=data.message_text,
            status=status,
            ai_feedback=feedback
        )

        db.add(message)
        db.commit()
        db.refresh(message)

        return {
            "status": "success",
            "moderation_result": status,
            "message_id": message.id,
            "feedback": feedback
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Message processing failed: {str(e)}"
        )


@router.get("/channel/{channel_id}")
def get_channel_messages(channel_id: int, db: Session = Depends(get_db)):

    messages = db.query(MessageDB).filter(
        MessageDB.channel_id == channel_id
    ).all()

    return {
        "status": "success",
        "messages": messages
    }