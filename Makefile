SHELL = bash

DOCKERCOMPOSE:=$(shell which docker-compose 2>/dev/null || echo "docker compose")

include .env
-include .env.local

help:
	@echo "clean_image: clear old dangling images to save space"
	@echo "setup: build according to docker-compose.yaml"
	@echo "up: run the services according to docker-compose.yaml"

TEMP_ENV := .env.tmp

prep_env: .env
	@cat .env > ${TEMP_ENV}
	@echo "" >> ${TEMP_ENV}
	-@cat .env.local >> ${TEMP_ENV}
	@echo Created temp env ${TEMP_ENV}

clean_image: prep_env
	sudo docker image prune -f

setup: clean_image prep_env
	sudo ${DOCKERCOMPOSE} --env-file ${TEMP_ENV} build \
		file_service

up: prep_env
	sudo ${DOCKERCOMPOSE} --env-file ${TEMP_ENV} up -d file_service

manual_up: prep_env
	sudo ${DOCKERCOMPOSE} --env-file ${TEMP_ENV} up file_service

down: prep_env
	sudo ${DOCKERCOMPOSE} --env-file ${TEMP_ENV} down