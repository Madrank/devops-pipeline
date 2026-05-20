# Démo DevOps Pipeline

## 1. Tests et lint

```bash
# Depuis la racine du projet
make test
```

Résultat attendu :
```
tests/test_app.py::TestAccueil::test_retourne_statut         PASSED
tests/test_app.py::TestAccueil::test_endpoint_sante          PASSED
tests/test_app.py::TestItems::test_pagination_par_defaut     PASSED
...
9 passed in 0.90s
```

```bash
make lint
# 0 erreurs flake8
```

## 2. Lancer l'application Flask

```bash
make run
# http://localhost:5000
```

Tester les endpoints :

```bash
# Page d'accueil
curl http://localhost:5000/
# → {"service":"devops-pipeline-demo","status":"en cours","version":"1.0.0"}

# Healthcheck
curl http://localhost:5000/health
# → {"status":"sain"}

# Liste paginée
curl http://localhost:5000/api/items?page=2&limit=3
# → {"page":2,"limit":3,"items":[{"id":4,"name":"Élément 4"},...],"total":100}

# Création
curl -X POST http://localhost:5000/api/items -H "Content-Type: application/json" -d '{"name":"test"}'
# → {"id":101,"name":"test","created":true}

# Métriques Prometheus
curl http://localhost:5000/metrics
```

## 3. Stack complet avec monitoring

```bash
make docker-up
```

| Service | URL |
|---------|-----|
| Application | http://localhost:5000 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 (admin/admin) |

## 4. Déploiement Terraform

```bash
cd terraform
terraform plan
# Vérifie les ressources AWS qui seront créées
terraform apply
# Provisionne : EC2 + Security Group + Elastic IP
```

## 5. Pipeline CI/CD (GitHub Actions)

Le workflow `.github/workflows/ci-cd.yml` s'exécute automatiquement à chaque push sur `main` :

```
Lint (flake8) → Test (pytest + coverage) → Build (Docker multi-stage + push GHCR) → Deploy (Terraform AWS)
```

Voir les runs : https://github.com/Madrank/devops-pipeline/actions
