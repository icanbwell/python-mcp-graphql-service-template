.PHONY:devsetup
devsetup: ## one time setup for devs
	pip3 install --user pipenv && \
	pipenv install --dev

.PHONY:devdocker
devdocker: ## Builds the docker for dev
	docker-compose build --parallel

.PHONY: run
run: ## runs Flask app
	pipenv run flask run

.PHONY: up
up: ## starts docker containers
	docker-compose up --build -d && \
	echo "waiting for {{cookiecutter.project_slug}} service to become healthy" && \
	while [ "`docker inspect --format {{ '{{.State.Health.Status}}' }} {{cookiecutter.docker_image_name}}`" != "healthy" ]; do printf "." && sleep 2; done && \
	echo "{{cookiecutter.project_slug}} Service: http://localhost:5000/graphql"

.PHONY: down
down: ## stops docker containers
	docker-compose down --remove-orphans

.PHONY: update
update: ## updates packages
	pipenv update && \
	make down && \
	make devdocker && \
	make up

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help.
	# from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:tests
tests: ## Runs all the tests
	docker-compose run --rm --name {{cookiecutter.project_slug}}_tests dev pytest tests

.PHONY:shell
shell: up ## Brings up the bash shell in dev docker
	docker-compose run --rm --name {{cookiecutter.project_slug}}_shell dev /bin/sh

.PHONY:clean-pre-commit
clean-pre-commit: ## removes pre-commit hook
	rm -f .git/hooks/pre-commit

.PHONY:setup-pre-commit
setup-pre-commit: Pipfile.lock
	cp ./pre-commit-hook ./.git/hooks/pre-commit

.PHONY:run-pre-commit
run-pre-commit: setup-pre-commit
	./.git/hooks/pre-commit
