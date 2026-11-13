
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
4. Explain concepts using simple real-world examples.
5. Use short headings and paragraphs.
6. Use bullet points for lists and comparisons.
7. Never use Markdown tables.
8. Avoid unnecessary introductions and repeated information.
9. For programming questions, provide simple code and brief explanations.
10. For revision requests, provide concise exam-ready notes.
11. For practice requests, provide clearly numbered questions.
12. Always finish every sentence and list.
13. Include a short conclusion when useful.

CONVERSATION RULES:

- Remember the previous messages in the current conversation.
- Understand follow-up questions using earlier context.
- If the student says "explain more", refer to the previous topic.
- If the student asks for another example, continue the same topic.
- Do not repeat the entire previous answer unnecessarily.
- Treat each new conversation independently.
"""


def ask_ai(
    question: str,
    conversation_history: list[dict] | None = None,
) -> str:

    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        }
    ]

    # Add previous conversation messages.
    if conversation_history:
        messages.extend(conversation_history[-20:])

    # Add the latest question.
    messages.append(
        {
            "role": "user",
            "content": question,
        }
    )

    response = client.chat.completions.create(
        model=MODEL_NAME,
        messages=messages,
        max_completion_tokens=1600,
        temperature=0.3,
    )

    choice = response.choices[0]
    answer = choice.message.content

    print("AI FINISH REASON:", choice.finish_reason)

    if not answer:
        raise RuntimeError("The AI provider returned an empty response.")

    if choice.finish_reason == "length":
        raise RuntimeError(
            "The AI response was incomplete. Please try a shorter question."
        )

    return answer.strip()
