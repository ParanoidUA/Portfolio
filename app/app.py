from flask import Flask, render_template

app = Flask(__name__)

@app.get("/")
def index():
    # Можеш передавати змінні у шаблон:
    return render_template("index.html", title="My Portfolio", ip="91.98.40.46")

@app.get("/health")
def health():
    return "ok"
