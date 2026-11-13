
import os

from dotenv import load_dotenv
from groq import Groq

load_dotenv()

API_KEY = os.getenv("GROQ_API_KEY")

if not API_KEY:
    raise RuntimeError("GROQ_API_KEY is missing from .env")

client = Groq(api_key=API_KEY)

MODEL_NAME = "openai/gpt-oss-20b"

SYSTEM_PROMPT = """
You are AI Mate, a friendly academic tutor for students.

Your goal is to make learning simple, clear and easy to understand.

RESPONSE RULES:

1. Use simple English suitable for students.
2. Keep answers short, relevant and complete.
3. Answer exactly what the student asks.
4. Explain difficult concepts with simple real-world examples.
5. Use short headings and paragraphs.
6. Use bullet points for lists and comparisons.
7. NEVER use Markdown tables.
8. Avoid unnecessary introductions and repeated information.
9. For programming questions, provide simple code and brief explanations.
10. For revision requests, provide concise exam-ready notes.
11. For practice requests, provide clearly numbered questions.
12. Always finish every sentence and list.
13. Include a short conclusion when useful.
14. Do not add unrelated information.

FORMATTING RULES:

- Use Markdown headings when necessary.
- Use bullet points instead of tables.
- Keep paragraphs short.
- Do not create wide layouts or multi-column content.
- Never intentionally leave an answer unfinished.

IMPORTANT:
Prefer a short, complete answer over a long, incomplete answer.
"""


def ask_ai(question: str) -> str:

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=[
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "user",
                "content": question,
            },
        ],
        max_completion_tokens=1600,
        temperature=0.3,
    )

    choice = response.choices[0]
    answer = choice.message.content

    print("AI FINISH REASON:", choice.finish_reason)
    print("AI RESPONSE:", answer)

    # Retry once if the response reaches the token limit.
    if choice.finish_reason == "length":

        print("AI response reached token limit. Retrying...")

        retry_response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "system",
                    "content": SYSTEM_PROMPT
                    + "\nKeep the answer very concise. "
                    + "Use only short paragraphs and bullet points. "
                    + "Do not use tables.",
                },
                {
                    "role": "user",
                    "content": question,
                },
            ],
            max_completion_tokens=1200,
            temperature=0.2,
        )

        choice = retry_response.choices[0]
        answer = choice.message.content

        print("RETRY FINISH REASON:", choice.finish_reason)
        print("RETRY RESPONSE:", answer)

    if not answer:
        raise RuntimeError("The AI provider returned an empty response.")

    if choice.finish_reason == "length":
        raise RuntimeError(
            "The response could not be completed. Please try a shorter question."
        )

    return answer.strip()
