
import os
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, auth

# Use Render Secret File when configured.
# Otherwise, use the local JSON file.
local_credentials = (
    Path(__file__).resolve().parents[2]
    / "firebase-service-account.json"
)

credential_path = os.getenv(
    "FIREBASE_CREDENTIALS_PATH",
    str(local_credentials),
)

# Initialize Firebase Admin only once.
if not firebase_admin._apps:
    cred = credentials.Certificate(credential_path)
    firebase_admin.initialize_app(cred)


def verify_firebase_token(token: str):
    """Verify a Firebase ID token and return decoded user data."""
    return auth.verify_id_token(token)
