
import os

from dotenv import load_dotenv
from groq import Groq

load_dotenv()

API_KEY = os.getenv("GROQ_API_KEY")

if not API_KEY:
    raise RuntimeError("GROQ_API_KEY is missing from .env")

client = Groq(api_key=API_KEY)

MODEL_NAME = "openai/gpt-oss-20b"


def ask_ai(question: str) -> str:
    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are AI BenchMate, a helpful academic tutor. "
                    "Explain concepts in simple language with examples. "
                    "Use headings and bullet points when useful. "
                    "Keep answers focused and student-friendly."
                ),
            },
            {
                "role": "user",
                "content": question,
            },
        ],
        max_completion_tokens=800,
        temperature=0.4,
    )

    answer = response.choices[0].message.content

    if not answer:
        raise RuntimeError("The AI provider returned an empty response.")

    return answer
