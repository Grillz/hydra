REGISTRY_URL=293135079892.dkr.ecr.us-west-2.amazonaws.com
COMPONENT=hydra
NAMESPACE=security
TAG=spike
HELM_INSTANCE=$(shell helm list | grep ${COMPONENT} | cut -f1)

deploy-image:
	aws ecr get-login | bash
	docker build -t ${REGISTRY_URL}/${COMPONENT}:${TAG} .
	docker push ${REGISTRY_URL}/${COMPONENT}:${TAG}

helm-start:
	helm install --namespace ${NAMESPACE} ./helm/hydra

compose:
	SYSTEM_SECRET=passwordtutorial DOCKER_IP=localhost docker-compose up --build

helm-stop:
	-@ if [ -z '${HELM_INSTANCE}' ]; then echo 'Helm package ${COMPONENT} not found' && exit 1; fi
	-helm delete --purge ${HELM_INSTANCE}

docker-clean:
	-docker-compose down
	-docker volume rm $(shell docker volume ls)
	-docker rmi $(shell docker images -q)

.PHONY: compose
