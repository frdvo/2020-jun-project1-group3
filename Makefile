TAG ?= $(shell git rev-parse --short HEAD)
REPO_URL ?= $(shell cd terraform/&&terraform output -json ecr_module | jq .ecr | jq -r .repository_url)
CONTAINER_NAME ?= webapp
RUNNER ?= docker-compose run --rm runner
BUCKET_NAME?=

.PHONY: deploy
deploy:
	@echo 🔨🧟🛠️Deploying all in one...
	cd terraform/&&make deploy

.PHONY: destroy
destroy:
	@echo 💥💥💥💥🧨💣Destroying...
	cd terraform/&&make destroy

# RUN_AWS ?= docker-compose run --rm 3m
# BUCKET_NAME?=
# .PHONY:create_bucket
# create_bucket:
# 	BUCKET_NAME=$(BUCKET_NAME) $(RUN_AWS) make _create_bucket

# .PHONY:_create_bucket
# _create_bucket:
# 	bash create_bucket.sh

# .PHONY:delete_bucket
# delete_bucket:
# 	BUCKET_NAME=$(BUCKET_NAME) $(RUN_AWS) make _delete_bucket

# .PHONY:_delete_bucket
# _delete_bucket:
# 	bash delete_bucket.sh

# cleanDocker:
# 	docker-compose down --remove-orphans

# clean: cleanDocker
# 	rm -f .env