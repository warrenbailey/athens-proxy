GIT_REPO=https://github.com/gomods/athens.git
SOURCE_DIR=athens-proxy/.athens-source
ATHENS_CHART_DIR=${SOURCE_DIR}/
ATHENS_VERSION=$(shell cat VERSION)
CHART_REPO := http://jenkins-x-chartmuseum:8080
CURRENT=$(pwd)
NAME := athens-proxy
OS := $(shell uname)

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init: 
	helm init --client-only

setup: init init_submodule
	helm repo add jenkinsxio https://storage.googleapis.com/chartmuseum.jenkins-x.io

build: clean setup
	helm dependency build athens-proxy
	helm lint athens-proxy

install: clean setup build
	helm install athens-proxy --name ${NAME}

upgrade: clean setup build
	helm upgrade ${NAME} athens-proxy

delete:
	helm delete --purge ${NAME} athens-proxy

clean:
	rm -rf athens-proxy/charts
	rm -rf athens-proxy/${NAME}*.tgz
	rm -rf athens-proxy/requirements.lock
	rm -rf athens-proxy/${SOURCE_DIR} 2>/dev/null

release: clean build
	sed -i -e "s/version:.*/version: $(VERSION)/" athens-proxy/Chart.yaml
	helm package athens-proxy
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts

init_submodule:
	@echo "Getting Athens ${ATHENS_VERSION} from ${GIT_REPO}"
	git clone --branch ${ATHENS_VERSION} ${GIT_REPO} ${SOURCE_DIR} 2>/dev/null; true
	cp -r ${SOURCE_DIR}/charts/proxy/* .
	