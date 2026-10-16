import os
from flask import Flask, jsonify

app = Flask(__name__)

LOGIN = os.environ.get("LAB_LOGIN", "pr0stak")
TOKEN = os.environ.get("LAB_TOKEN", "1fac4572bc57e2acbfadb1af59f5664f")


@app.get("/")
def index():
    size = os.environ.get("rocket_size", "ьedium")
    return f"Hello from {LOGIN}! Rocket size: {size}\n"


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


@app.get("/proof")
def proof():
    return jsonify(login=LOGIN, token=TOKEN), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
