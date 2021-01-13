TAG ?= $(shell git rev-parse --short HEAD)
REPO_URL ?= $(shell cd terraform/&&terraform output -json ecr_module | jq .ecr | jq -r .repository_url)
CONTAINER_NAME ?= webapp
RUNNER ?= docker-compose run --rm 3m
BUCKET_NAME?=
TAG ?= $(shell git rev-parse --short HEAD)
REPO_URL ?= $(shell terraform output -json ecr_module | jq .ecr | jq -r .repository_url)
CONTAINER_NAME ?= webapp

.PHONY: init
init:
	@echo "🏁🚥 Initializing...."
	$(RUNNER) terraform -chdir=./terraform init -backend-config="bucket=${tf_backend_bucket}"

.PHONY: plan
plan:
	@echo "🌏🚜Planning...."
	$(RUNNER) terraform -chdir=./terraform plan -out tf.plan -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'
	$(RUNNER) aws s3 cp tf.plan s3://${tf_backend_bucket}/

.PHONY: apply
apply:
	@echo "⛅🌏🏗️Applying...."
	$(RUNNER) aws s3 cp s3://${tf_backend_bucket}/tf.plan .
	$(RUNNER) terraform -chdir=./terraform apply -auto-approve "tf.plan"

.PHONY: deploy-wp
deploy-wp:
	@echo "📦🏗️⛅Deploying Wordpress customized image..."
	$(RUNNER) terraform -chdir=./terraform apply -auto-approve -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'

.PHONY: destroy
destroy:
	@echo "💥💥💥💥💥💥🧨💣Destroying...."
	make init
	$(RUNNER) terraform -chdir=./terraform terraform destroy -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'

.PHONY: deploy
deploy:
	@echo 🔨🧟🛠️Deploying all in one...
	make init
	make plan
	make apply
	cd ../docker/&&make login
	cd ../docker/&&make build
	cd ../docker/&&make publish
	make deploy-wp
	@echo 🙌🙃🙌Deployment finished!

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

cleanDocker:
 	docker-compose down --remove-orphans

# clean: cleanDocker
# 	rm -f .env