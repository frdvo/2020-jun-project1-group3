TAG ?= $(shell git rev-parse --short HEAD)
REPO_URL ?= $(shell $(COMPOSE_RUN_TERRAFORM) -chdir=./terraform output -json ecr_module | $(COMPOSE_RUN_JQ) .ecr.repository_url)
CONTAINER_NAME ?= webapp
COMPOSE_RUN_TERRAFORM ?= docker-compose run --rm terraform
COMPOSE_RUN_AWS ?= docker-compose run --rm aws
COMPOSE_RUN_JQ ?= docker-compose run --rm jq
ENVFILE ?= env.template
acm_cert_arn ?=
AWS_ACCESS_KEY_ID ?=
AWS_REGION ?=
AWS_SECRET_ACCESS_KEY ?=
domain_name ?=
hosted_zone_id ?=
ssh_allowed_cidr ?=
tf_backend_bucket ?=


.PHONY: login
login:
	@echo "🏗Retrieving an authentication token and authenticate your Docker client to your registry"
	$(COMPOSE_RUN_AWS) ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${REPO_URL}

.PHONY: build
build:
	@echo "🏷️📦🏗️Building and tagging container..."
	docker build -f docker/Dockerfile --tag ${REPO_URL}:${TAG} .

.PHONY: publish
publish:
	@echo "🚀📦⛅Pushing container..."
	docker push ${REPO_URL}:${TAG}

.PHONY: init
init:
	@echo "🏁🚥 Initializing...."
	$(COMPOSE_RUN_TERRAFORM) -chdir=./terraform init -backend-config="bucket=${tf_backend_bucket}"

.PHONY: plan
plan:
	@echo "🌏🚜Planning...."
	$(COMPOSE_RUN_TERRAFORM) -chdir=./terraform plan -out tf.plan -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'
	$(COMPOSE_RUN_AWS) s3 cp ./terraform/tf.plan s3://${tf_backend_bucket}/

.PHONY: apply
apply:
	@echo "⛅🌏🏗️Applying...."
	$(COMPOSE_RUN_AWS) s3 cp s3://${tf_backend_bucket}/tf.plan ./terraform/tf.plan
	$(COMPOSE_RUN_TERRAFORM) -chdir=./terraform apply  "tf.plan"

.PHONY: deploy-wp
deploy-wp:
	@echo "📦🏗️⛅Deploying Wordpress customized image..."
	$(COMPOSE_RUN_TERRAFORM) -chdir=./terraform apply -auto-approve -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'

.PHONY: destroy
destroy:
	@echo "💥💥💥💥💥💥🧨💣Destroying...."
	make init
	$(COMPOSE_RUN_TERRAFORM) -chdir=./terraform destroy -var 'app_image=${REPO_URL}' -var 'image_tag=${TAG}' -var 'hosted_zone_id=${hosted_zone_id}' -var 'domain_name=${domain_name}' -var 'acm_cert_arn=${acm_cert_arn}' -var 'ssh_allowed_cidr=${ssh_allowed_cidr}'

.PHONY: deploy
deploy:
	@echo 🔨🧟🛠️Deploying all in one...
	make init
	make plan
	make apply
	make login
	make build
	make publish
	make deploy-wp
	@echo 🙌🙃🙌Deployment finished!

cleanDocker:
	docker-compose down --remove-orphans
