
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field

from app.services.ai_service import ask_ai
from app.core.auth import get_current_user
from app.core.rate_limiter import check_rate_limit

router = APIRouter()


class HomeworkRequest(BaseModel):
    question: str = Field(
        min_length=3,
        max_length=2000,
    )


@router.post("/ask")
def ask_homework(
    request: HomeworkRequest,
    current_user: dict = Depends(get_current_user),
):
    # Identify the authenticated Firebase user.
    user_id = current_user["uid"]

    # Check the user's request limit.
    allowed, retry_after = check_rate_limit(user_id)

    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="You have reached your AI request limit. Please try again shortly.",
            headers={"Retry-After": str(retry_after)},
        )

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
