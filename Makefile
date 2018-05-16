VER ?= $$(git describe --tags)
IMAGE_NAME = anypoint-tf-efs-from-public-ip
TAG := $(IMAGE_NAME):$(VER)
DOCKER_REGISTRY ?= devdocker.mulesoft.com:18078/mulesoft

#### BUILD DOCKER IMAGE with the generated artifacts
.PHONY: build-image
build-image:
	docker build -f Dockerfile -t $(TAG) .

#### PUSH DOCKER IMAGE
.PHONY: push-image
push-image:
	docker tag $(TAG) $(DOCKER_REGISTRY)/$(TAG)
	docker push $(DOCKER_REGISTRY)/$(TAG)
