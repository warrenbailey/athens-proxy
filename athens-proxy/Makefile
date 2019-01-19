GIT_REPO=https://github.com/gomods/athens.git
SOURCE_DIR=athens-source
ATHENS_VERSION=$(shell cat ../VERSION)
ATHENS_CHART_DIR=${SOURCE_DIR}/
CHART_REPO := http://jenkins-x-chartmuseum:8080
CURRENT=$(pwd)
NAME := athens 
OS := $(shell uname)

init: 
	helm init --client-only

setup: init init_submodule init_version
	helm repo add jenkins-x-api https://chartmuseum.build.cd.jenkins-x.io 	
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

release: clean build
	sed -i -e "s/version:.*/version: $(shell cat ./VERSION)/" Chart.yaml
	sed -i -e "s/tag:.*/tag: $(shell cat ./VERSION)/" values.yaml


init_submodule:
	@echo "Getting Athens ${ATHENS_VERSION} from ${GIT_REPO}"
	git clone --branch ${ATHENS_VERSION} ${GIT_REPO} ${SOURCE_DIR} 2>/dev/null
	cp -r ${SOURCE_DIR}/charts/proxy/* .

init_version:
	git tag ${ATHENS_VERSION}
	echo $(jx-release-version) > ./VERSION