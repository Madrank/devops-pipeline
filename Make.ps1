param(
    [string]$Target = "help"
)

$Python = ".\.venv\Scripts\python.exe"

switch ($Target) {
    "help" {
        Write-Output "Utilisation : .\Make.ps1 <cible>"
        Write-Output ""
        Write-Output "Cibles disponibles :"
        Write-Output "  install     Installer les dependances Python"
        Write-Output "  lint        Verifier la qualite du code avec flake8"
        Write-Output "  test        Executer les tests avec couverture"
        Write-Output "  build       Construire l'image Docker"
        Write-Output "  run         Lancer l'application Flask en local"
        Write-Output "  docker-up   Demarrer tous les services avec docker-compose"
        Write-Output "  docker-down Arreter tous les services"
        Write-Output "  clean       Supprimer les fichiers cache Python"
    }
    "install" {
        & $Python -m pip install -r app/requirements.txt
    }
    "lint" {
        & $Python -m flake8 app/ --count --statistics
    }
    "test" {
        Push-Location app
        & "..\$Python" -m pytest tests/ -v --cov=. --cov-report=term
        Pop-Location
    }
    "build" {
        docker build -t devops-pipeline-demo:latest .
    }
    "run" {
        Push-Location app
        & "..\$Python" -m flask run --host=0.0.0.0 --port=5000
        Pop-Location
    }
    "docker-up" {
        docker-compose up -d --build
    }
    "docker-down" {
        docker-compose down
    }
    "clean" {
        Remove-Item -Recurse -Force app/__pycache__, app/tests/__pycache__, .pytest_cache -ErrorAction SilentlyContinue
    }
    default {
        Write-Output "Cible inconnue : $Target"
        exit 1
    }
}
