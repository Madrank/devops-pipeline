import os
import sys

import pytest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))  # noqa: E402
from app import app as flask_app  # noqa: E402


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


class TestAccueil:
    def test_retourne_statut(self, client):
        resp = client.get("/")
        assert resp.status_code == 200
        data = resp.get_json()
        assert data["status"] == "en cours"
        assert data["service"] == "devops-pipeline-demo"

    def test_endpoint_sante(self, client):
        resp = client.get("/health")
        assert resp.status_code == 200
        assert resp.get_json()["status"] == "sain"


class TestItems:
    def test_pagination_par_defaut(self, client):
        resp = client.get("/api/items")
        assert resp.status_code == 200
        data = resp.get_json()
        assert data["page"] == 1
        assert data["limit"] == 10
        assert len(data["items"]) == 10

    def test_pagination_personnalisee(self, client):
        resp = client.get("/api/items?page=2&limit=5")
        assert resp.status_code == 200
        data = resp.get_json()
        assert data["page"] == 2
        assert data["limit"] == 5
        assert len(data["items"]) == 5
        assert data["items"][0]["id"] == 6

    def test_creation_item_succes(self, client):
        resp = client.post("/api/items", json={"name": "NouvelItem"})
        assert resp.status_code == 201
        data = resp.get_json()
        assert data["created"] is True
        assert data["name"] == "NouvelItem"

    def test_creation_item_sans_nom(self, client):
        resp = client.post("/api/items", json={})
        assert resp.status_code == 400
        assert resp.get_json()["error"] == "le nom est requis"


class TestEcho:
    def test_compteur_incremente(self, client):
        resp1 = client.post("/api/echo", json={"msg": "bonjour"})
        assert resp1.status_code == 200
        assert resp1.get_json()["request_number"] == 1

        resp2 = client.post("/api/echo", json={"msg": "monde"})
        assert resp2.status_code == 200
        assert resp2.get_json()["request_number"] == 2


class TestErreurs:
    def test_404_retourne_json(self, client):
        resp = client.get("/inexistant")
        assert resp.status_code == 404
        assert resp.get_json()["error"] == "non trouvé"

    def test_500_retourne_json(self, client):
        with pytest.raises(RuntimeError):
            client.get("/api/error")
