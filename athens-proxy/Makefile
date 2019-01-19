GIT_REPO=https://github.com/gomods/athens.git
SOURCE_DIR=.athens-source
ATHENS_VERSION=$(shell cat ../VERSION)
ATHENS_CHART_DIR=${SOURCE_DIR}/
CHART_REPO := http://jenkins-x-chartmuseum:8080
CURRENT=$(pwd)
NAME := athens-proxy
OS := $(shell uname)

init: 
	helm init --client-only

setup: init init_submodule init_version
	helm repo add jenkinsxio https://chartmuseum.jx.cd.jenkins-x.io 

build: clean setup
	helm dependency build
	helm lint

install: clean setup build
	helm install . --name ${NAME}

upgrade: clean setup build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz
	rm -rf requirements.lock
	rm -rf ${SOURCE_DIR} 2>/dev/null
	rm -rf VERSION

release: clean build
	sed -i -e "s/version:.*/version: $(shell cat ./VERSION)/" Chart.yaml
	helm package .
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(shell cat ./VERSION).tgz" $(CHART_REPO)/api/charts

init_submodule:
	@echo "Getting Athens ${ATHENS_VERSION} from ${GIT_REPO}"
	git clone --branch ${ATHENS_VERSION} ${GIT_REPO} ${SOURCE_DIR} 2>/dev/null; true
	cp -r ${SOURCE_DIR}/charts/proxy/* .

init_version:
	git tag ${ATHENS_VERSION} 2> /dev/null; true
	echo $(shell jx-release-version) > ./VERSION
	