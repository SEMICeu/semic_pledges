FROM python:3.11-slim

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app
COPY app /app

RUN adduser -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

CMD [ "python", "main.py" ]