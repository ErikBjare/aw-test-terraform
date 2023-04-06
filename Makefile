DOCKER_IMAGE_NAME := aw-test-terraform
TERRAFORM_DIR := ./terraform

.PHONY: all build-docker-image terraform-init terraform-apply terraform-destroy clean

all: build-docker-image terraform-init terraform-apply

build-docker-image: Dockerfile
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-push:
	docker tag aw-test-terraform:latest erikbjare/aw-test-terraform:latest
	docker push erikbjare/aw-test-terraform:latest
	docker rmi erikbjare/aw-test-terraform:latest
	docker pull erikbjare/aw-test-terraform:latest

terraform-init:
	cd $(TERRAFORM_DIR) && terraform init

terraform-apply: terraform-init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

terraform-destroy:
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

clean:
	cd $(TERRAFORM_DIR) && rm -rf .terraform* terraform.tfstate*
