import os
import time
from flask import Flask, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

metrics.info("app_info", "Informations de l'application", version="1.0.0")

REQUEST_COUNT = 0


@app.route("/")
def home():
    return jsonify({"service": "devops-pipeline-demo", "status": "en cours", "version": "1.0.0"})


@app.route("/health")
def health():
    return jsonify({"status": "sain"}), 200


@app.route("/api/items", methods=["GET"])
def get_items():
    page = request.args.get("page", 1, type=int)
    limit = request.args.get("limit", 10, type=int)
    start = (page - 1) * limit + 1
    items = [{"id": i, "name": f"Élément {i}"} for i in range(start, page * limit + 1)]
    return jsonify(
        {"page": page, "limit": limit, "items": items, "total": 100}
    )


@app.route("/api/items", methods=["POST"])
def create_item():
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "le nom est requis"}), 400
    return jsonify({"id": 101, "name": data["name"], "created": True}), 201


@app.route("/api/echo", methods=["POST"])
def echo():
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    data = request.get_json()
    time.sleep(0.05)
    return jsonify({"echo": data, "request_number": REQUEST_COUNT})


@app.route("/api/error")
def trigger_error():
    raise RuntimeError("Ceci est une erreur de test pour le monitoring")


@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "non trouvé"}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "erreur interne du serveur"}), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
