.PHONY: env
env:
	if [ ! -e .env ]; then cp .env.example .env; fi;

.PHONY: build-dev-no-cache
build-dev-no-cache: env
	docker compose -f docker-compose.dev.yaml build --no-cache

.PHONY: build-prod-no-cache
build-prod-no-cache: env
	docker compose -f docker-compose.prod.yaml build --no-cache

.PHONY: run-dev
run-dev: env
	docker compose -f docker-compose.dev.yaml up -d --build

.PHONY: run-prod
run-prod: env
	docker compose  -f docker-compose.prod.yaml up -d --build

.PHONY: clean-dev
clean-dev:
	docker compose -f docker-compose.dev.yaml down --remove-orphans
	rm -rf ./data || true
	rm -rf .env || true

.PHONY: clean-prod
clean-prod:
	docker compose -f docker-compose.prod.yaml down --remove-orphans
	rm -rf ./data
	rm -rf .env