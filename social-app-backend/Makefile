.PHONY: help build up down restart logs migrate seed init test

help:
	@echo "Available commands:"
	@echo "  make build    - Build Docker containers"
	@echo "  make up       - Start all services"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - View logs"
	@echo "  make migrate  - Run Django migrations"
	@echo "  make init     - Initialize database"
	@echo "  make seed     - Seed test data"
	@echo "  make test     - Run tests"

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "✅ Services started!"
	@echo "Django: http://localhost:8000"
	@echo "FastAPI: http://localhost:8001"
	@echo "Admin: http://localhost:8000/admin"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

migrate:
	docker-compose exec django python manage.py makemigrations
	docker-compose exec django python manage.py migrate

init:
	docker-compose exec django python scripts/init_db.py

seed:
	docker-compose exec django python scripts/seed_data.py

test:
	docker-compose exec django python manage.py test

shell:
	docker-compose exec django python manage.py shell
