
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.services.ai_service import ask_ai

router = APIRouter()


class HomeworkRequest(BaseModel):
    question: str = Field(
        min_length=3,
        max_length=2000,
    )


@router.post("/ask")
def ask_homework(request: HomeworkRequest):
    try:
        answer = ask_ai(request.question)

        return {
            "question": request.question,
            "answer": answer,
            "status": "success",
        }

    except Exception as e:
        print(f"Homework AI Error: {e}")

        raise HTTPException(
            status_code=503,
            detail="AI service is temporarily unavailable. Please try again.",
        )
