# =============================================================
# app.py
# Proyecto: DevOps STF — Soluciones Tecnológicas del Futuro
# Descripción: Aplicación web Flask para el sector financiero
# =============================================================

from flask import Flask, jsonify
from datetime import datetime
import os
import socket

app = Flask(__name__)

# ── Ruta principal ────────────────────────────────────────────
@app.route("/")
def index():
    return jsonify({
        "proyecto": "Soluciones Tecnológicas del Futuro",
        "version": "1.0.0",
        "mensaje": "API DevOps STF funcionando correctamente",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "servidor": socket.gethostname()
    })

# ── Health check para Docker ──────────────────────────────────
@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }), 200

# ── Información del entorno ───────────────────────────────────
@app.route("/info")
def info():
    return jsonify({
        "entorno": os.getenv("FLASK_ENV", "development"),
        "host": socket.gethostname(),
        "python_version": os.popen("python3 --version").read().strip()
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)