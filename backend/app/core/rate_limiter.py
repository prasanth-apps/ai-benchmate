
import time
from collections import defaultdict, deque
from threading import Lock

MAX_REQUESTS = 10
WINDOW_SECONDS = 60

user_requests = defaultdict(deque)
rate_limit_lock = Lock()


def check_rate_limit(user_id: str):
    current_time = time.monotonic()

    with rate_limit_lock:
        requests = user_requests[user_id]

        # Remove requests outside the time window.
        while requests and current_time - requests[0] >= WINDOW_SECONDS:
            requests.popleft()

        if len(requests) >= MAX_REQUESTS:
            retry_after = int(
                WINDOW_SECONDS - (current_time - requests[0])
            ) + 1

            return False, retry_after

        requests.append(current_time)

        return True, 0
