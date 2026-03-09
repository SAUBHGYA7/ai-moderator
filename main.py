from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import Base, engine
from community import router as community_router
app = FastAPI()
from pydantic import BaseModel

class ChatRequest(BaseModel):
    message: str


@app.post("/chat")
async def chat(req: ChatRequest):
    
    return {
        "reply": f"You said: {req.message}"
    }
# Allow frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables
Base.metadata.create_all(bind=engine)
app.include_router(community_router)


@app.get("/")
def root():
    return {"message": "PeerSpace backend running"}