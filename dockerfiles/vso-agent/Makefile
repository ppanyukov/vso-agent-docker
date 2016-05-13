# Builds the docker images for vso-agent

# Used to push to docker hub in push_hub target.
# Can change this as arg to make, e.g. make all DOCKER_USER_NAME=whatever
DOCKER_USER_NAME := ppanyukov

# given taget name like this: centos7-0.4.5.image
# extract:
#	TAG=centos7-0.4.5
#	AGENT_OS=centos7
#	AGENT_VERSION=0.4.5 
DOCKER_IMAGE_NAME := vso-agent
DOCKER_IMAGE_TAG = $(patsubst %.image,%,$@)
DOCKER_IMAGE_FULL_TAG = $(DOCKER_IMAGE_NAME):$(patsubst %.image,%,$@)

DOCKER_AGENT_OS = $(word 1, $(subst -, ,$(DOCKER_IMAGE_TAG)))
DOCKER_AGENT_VERSION = $(word 2, $(subst -, ,$(DOCKER_IMAGE_TAG)))
DOCKER_BUILD_ARGS = --build-arg "z_vso_agent_version=@$(DOCKER_AGENT_VERSION)"

DOCKER_SOURCE_TAG = $(DOCKER_IMAGE_NAME):$(patsubst %.image,%,$<)
DOCKER_TARGET_TAG = $(DOCKER_IMAGE_NAME):$(patsubst %.image,%,$@)

centos7-latest.image: centos7-0.6.5.image
	docker tag $(DOCKER_SOURCE_TAG) $(DOCKER_TARGET_TAG)
	touch $@


centos7-0.4.5.image: centos7.Dockerfile
	@echo building $@ from $<
	docker build $(DOCKER_BUILD_ARGS) --tag $(DOCKER_IMAGE_FULL_TAG) -f $< .
	touch $@

centos7-0.6.5.image: centos7.Dockerfile
	@echo building $@ from $<
	docker build $(DOCKER_BUILD_ARGS) --tag $(DOCKER_IMAGE_FULL_TAG) -f $< .
	touch $@


ALL_IMAGES := centos7-0.4.5.image centos7-0.6.5.image centos7-latest.image

.PHONY: all
all: $(ALL_IMAGES)

.PHONY: clean
clean:
	-rm -f *.image
	-rm -f *.push


%.push : %.image
	@echo PUSHING $@ from $<
	docker tag $(DOCKER_SOURCE_TAG) $(DOCKER_USER_NAME)/$(DOCKER_SOURCE_TAG)
	docker push $(DOCKER_USER_NAME)/$(DOCKER_SOURCE_TAG)
	touch $@

PUSH_TARGETS := $(patsubst %.image,%.push,$(ALL_IMAGES))


.PHONY: push_hub
push_hub: $(PUSH_TARGETS)
	# docker tag $(DOCKER_SOURCE_TAG) $(DOCKER_USER_NAME)/$(DOCKER_SOURCE_TAG)
	# # docker login
	# docker push $(DOCKER_USER_NAME)/$(DOCKER_SOURCE_TAG)


