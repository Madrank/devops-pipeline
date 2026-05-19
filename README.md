# Pipeline DevOps

Pipeline CI/CD complet avec monitoring, infrastructure en tant que code (IaC) et conteneurisation.

## Architecture

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Lint    │ ──▶ │  Test    │ ──▶ │  Build   │ ──▶ │  Deploy  │
│ (flake8) │     │ (pytest) │     │ (Docker) │     │(Terraform│
└──────────┘     └──────────┘     └──────────┘     │  + AWS ) │
                                                    └──────────┘

Monitoring :
┌──────────┐     ┌──────────┐
│Prometheus│ ◀── │  Flask   │
│ :9090    │     │  App     │
└────┬─────┘     └──────────┘
     │
┌────▼─────┐
│ Grafana  │
│ :3000    │
└──────────┘
```

## Stack

| Couche | Technologie |
|--------|-------------|
| App | Python / Flask |
| Conteneur | Docker / Docker Compose |
| CI/CD | GitHub Actions |
| IaC | Terraform (AWS) |
| Monitoring | Prometheus + Grafana |
| Logs | AWS CloudWatch |

## Démarrage rapide

```bash
# Installer les dépendances
make install

# Lancer les tests
make test

# Exécuter en local
make run

# Stack complet avec monitoring
make docker-up
```

## Pipeline CI/CD

Le pipeline s'exécute à chaque push et PR :

1. **Lint** — vérification de la qualité du code avec flake8
2. **Test** — tests unitaires avec pytest et rapport de couverture
3. **Build** — image Docker multi-stage, poussée sur GHCR
4. **Deploy** — Terraform provisionne une instance EC2 AWS et exécute le conteneur

## Terraform

L'infrastructure est définie dans `terraform/` :

- Instance EC2 (t3.micro) avec IP élastique automatique
- Groupe de sécurité (HTTP/HTTPS/SSH)
- Script user_data qui installe Docker, pull l'image et configure CloudWatch

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Monitoring

Accéder aux dashboards de monitoring en local via docker-compose :

- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)

## Structure du projet

```
.
├── app/                  # Application Flask
│   ├── app.py           # Application principale
│   ├── requirements.txt # Dépendances
│   └── tests/           # Tests unitaires
├── terraform/            # Infrastructure en tant que code
│   ├── main.tf          # Ressources AWS
│   ├── variables.tf     # Configuration
│   └── outputs.tf       # URLs de déploiement
├── monitoring/           # Observabilité
│   ├── prometheus/      # Configuration des métriques
│   └── grafana/         # Dashboards
├── .github/workflows/   # Pipeline CI/CD
├── Dockerfile            # Build multi-stage
├── docker-compose.yml    # Environnement local
└── Makefile              # Automatisation
```
