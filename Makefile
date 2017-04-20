REGISTRY_URL=293135079892.dkr.ecr.us-west-2.amazonaws.com
COMPONENT=hydra
NAMESPACE=security
TAG=spike
HELM_INSTANCE=$(shell helm list | grep ${COMPONENT} | cut -f1)
TREBUCHET_AWS_REGION=eu-west-1
TREBUCHET_PARENT_DOMAIN=dev.datapipe.io
SSL_CERT_ARN=`aws acm list-certificates --region ${TREBUCHET_AWS_REGION} --query="CertificateSummaryList[?DomainName=='*.${TREBUCHET_PARENT_DOMAIN}'].[CertificateArn]" --output=text`
include .root

deploy-image:
	aws ecr get-login | bash
	docker build -t ${REGISTRY_URL}/${COMPONENT}:${TAG} .
	docker push ${REGISTRY_URL}/${COMPONENT}:${TAG}

helm-start:
	@echo ${SSL_CERT_ARN}
	@echo root user: ${ROOT_USER}
	@echo root password: ${ROOT_PASSWORD}
	helm install --namespace ${NAMESPACE} ./helm/hydra --set awsElbSslCert=${SSL_CERT_ARN},SYSTEM_SECRET=${SYSTEM_SECRET},ROOT_USER=${ROOT_USER},ROOT_PASSWORD=${ROOT_PASSWORD}

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
