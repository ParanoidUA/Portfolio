FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY templates/ ./templates/

# запуск дев-сервером Flask (як просив)
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
