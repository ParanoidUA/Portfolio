FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY templates/ ./templates/

# запуск дев-сервером Flask (як просив)
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]



# # syntax=docker/dockerfile:1
# FROM python:3.12-slim

# RUN apt-get update \
#  && apt-get install -y --no-install-recommends build-essential \
#  && rm -rf /var/lib/apt/lists/*

# WORKDIR /app

# # requirements.txt должен лежать рядом с app.py
# # Минимум: Flask==3.0.3
# COPY requirements.txt /app/requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

# COPY . /app

# EXPOSE 8000

# # В app.py должен быть app.run(host="0.0.0.0", port=8000)
# CMD ["python", "app.py"]
