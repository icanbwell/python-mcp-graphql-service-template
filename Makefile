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
	echo "waiting for ElasticSearch server to become healthy" && \
	while [ "`docker inspect --format {{.State.Health.Status}} elasticsearch`" != "healthy" ]; do printf "." && sleep 2; done && \
	echo "waiting for Provider Search service to become healthy" && \
	while [ "`docker inspect --format {{.State.Health.Status}} helix.providersearch`" != "healthy" ]; do printf "." && sleep 2; done && \
	echo "Elastic Search: https://localhost:9200/ (admin:admin)" && \
	echo "Elastic Search Kibana: http://localhost:5601/ (admin:admin)" && \
	echo "Provider Search Service: http://localhost:5000/graphql"

.PHONY: down
down: ## stops docker containers
	docker-compose down

.PHONY: clean
clean: down ## Cleans all the local docker setup
ifneq ($(shell docker image ls | grep "helixprovidersearch"| awk '{print $$1}'),)
	docker image ls | grep "helixprovidersearch" | awk '{print $$1}' | xargs docker image rm
endif
	# do it twice since some images are used by other images
ifneq ($(shell docker image ls | grep "helixprovidersearch"| awk '{print $$1}'),)
	docker image ls | grep "helixprovidersearch" | awk '{print $$1}' | xargs docker image rm || true
endif
ifneq ($(shell docker volume ls | grep "helixprovidersearch"| awk '{print $$2}'),)
	docker volume ls | grep "helixprovidersearch" | awk '{print $$2}' | xargs docker volume rm
endif

.PHONY: clean_data
clean_data: down ## Cleans all the local docker setup
ifneq ($(shell docker volume ls | grep "helixprovidersearch"| awk '{print $$2}'),)
	docker volume ls | grep "helixprovidersearch_es" | awk '{print $$2}' | xargs docker volume rm
endif

.PHONY: update
update: ## updates packages
	pipenv update && \
	make down && \
	make devdocker && \
	make up

.PHONY: init
init: ## sets up the index and sample data
	cd ./init/elasticsearch && \
	./init.sh && \
	cd ../..

.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help.
	# from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:tests
tests: ## Runs all the tests
	docker-compose run --rm --name helix_providersearch_tests dev pytest tests

.PHONY:shell
shell: up ## Brings up the bash shell in dev docker
	docker-compose run --rm --name helix_providersearch_shell dev /bin/sh

.PHONY:clean-pre-commit
clean-pre-commit: ## removes pre-commit hook
	rm -f .git/hooks/pre-commit

.PHONY:setup-pre-commit
setup-pre-commit: Pipfile.lock
	cp ./pre-commit-hook ./.git/hooks/pre-commit

.PHONY:run-pre-commit
run-pre-commit: setup-pre-commit
	./.git/hooks/pre-commit

.PHONY: dump-dev
dump-dev: ## downloads index from dev Elasticsearch server to data folder
	@echo "Enter Password for reader account: "; \
    read PASSWORD; \
    echo "Your password is ", $${PASSWORD}; \
	docker-compose run --rm --name elasticdump elasticdump elasticdump \
  	--input=https://reader:$${PASSWORD}@vpc-helix-elasticsearch-xeiyn2datxvmwhcxpcfykztv4a.us-east-1.es.amazonaws.com/practitioner-en/ \
  	--output=/data/practitioner-en.json \
  	--type=data; \
	docker-compose run --rm --name elasticdump elasticdump elasticdump \
  	--input=https://reader:$${PASSWORD}@vpc-helix-elasticsearch-xeiyn2datxvmwhcxpcfykztv4a.us-east-1.es.amazonaws.com/practice-en/ \
  	--output=/data/practice-en.json \
  	--type=data

.PHONY: load-dev
load-dev: ## loads index from data folder into local Elasticsearch
	docker-compose run -e NODE_TLS_REJECT_UNAUTHORIZED=0 --rm --name elasticdump elasticdump elasticdump \
  	--input=/data/practitioner-en.json \
  	--output=https://admin:admin@elasticsearch:9200/practitioner \
  	--type=data; \
  	docker-compose run -e NODE_TLS_REJECT_UNAUTHORIZED=0 --rm --name elasticdump elasticdump elasticdump \
  	--input=/data/practice-en.json \
  	--output=https://admin:admin@elasticsearch:9200/practice \
  	--type=data

.PHONY: copy-index-dev
copy-index-dev: dump-dev load-dev ## copies index from dev to local Elasticsearch
