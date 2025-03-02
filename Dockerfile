FROM python:3.11-slim


# Install system dependencies
RUN apt-get update \
    &&apt-get install -y --no-install-recommends gcc libpq-dev default-libmysqlclient-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r /app/requirements.txt

COPY django_blog /app
WORKDIR /app


EXPOSE 8000

CMD gunicorn -k uvicorn.workers.UvicornWorker -c gunicorn.conf.py django_blog.asgi:application