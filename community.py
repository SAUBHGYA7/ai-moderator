from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from database import SessionLocal
from models import Community

router = APIRouter(prefix="/communities", tags=["communities"])


# DATABASE CONNECTION
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# REQUEST MODEL
class CommunityCreate(BaseModel):
    name: str
    description: str


# CREATE COMMUNITY
@router.post("/")
def create_community(data: CommunityCreate, db: Session = Depends(get_db)):

    community = Community(
        name=data.name,
        description=data.description
    )

    db.add(community)
    db.commit()
    db.refresh(community)

    return community


# LIST ALL COMMUNITIES
@router.get("/")
def get_communities(db: Session = Depends(get_db)):

    communities = db.query(Community).all()

    return communities


# GET ONE COMMUNITY
@router.get("/{community_id}")
def get_community(community_id: int, db: Session = Depends(get_db)):

    community = db.query(Community).filter(Community.id == community_id).first()

    return community