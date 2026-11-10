
from fastapi import FastAPI

from app.routes import homework

app = FastAPI(
    title="AI BenchMate API",
    description="Backend API for the AI BenchMate student assistant",
    version="1.0.0",
)

app.include_router(
    homework.router,
    prefix="/api/homework",
    tags=["Homework Help"],
)


@app.get("/")
def home():
    return {
        "message": "Welcome to AI BenchMate API",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "AI BenchMate Backend",
    }
