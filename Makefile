PYTHON = .venv\Scripts\python.exe
SHELL = cmd.exe

.PHONY: help install lint test build run docker-up docker-down clean

help:
	@echo Utilisation : make ^<cible^>
	@echo.
	@echo Cibles disponibles :
	@echo   install     Installer les dependances Python
	@echo   lint        Verifier la qualite du code avec flake8
	@echo   test        Executer les tests avec couverture
	@echo   build       Construire l'image Docker
	@echo   run         Lancer l'application Flask en local
	@echo   docker-up   Demarrer tous les services avec docker-compose
	@echo   docker-down Arreter tous les services
	@echo   clean       Supprimer les fichiers cache Python

install:
	$(PYTHON) -m pip install -r app\requirements.txt

lint:
	$(PYTHON) -m flake8 app\ --count --statistics

test:
	cd app && ..\$(PYTHON) -m pytest tests\ -v --cov=. --cov-report=term

build:
	docker build -t devops-pipeline-demo:latest .

run:
	cd app && ..\$(PYTHON) -m flask run --host=0.0.0.0 --port=5000

docker-up:
	docker-compose up -d --build

docker-down:
	docker-compose down

clean:
	if exist app\__pycache__ rmdir /s /q app\__pycache__
	if exist app\tests\__pycache__ rmdir /s /q app\tests\__pycache__
	if exist .pytest_cache rmdir /s /q .pytest_cache
