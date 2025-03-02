import os

workers = int(os.environ.get("WORKERS", 1))

bind = "0.0.0.0:8000"
# worker_class = "gevent"
timeout = int(os.environ.get("TIMEOUT", 120))
keepalive = 5
