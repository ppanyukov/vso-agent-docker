# Builds the docker images

# Used to push to docker hub in push_hub target.
# Can change this as arg to make, e.g. make all DOCKER_USER_NAME=whatever
# DOCKER_USER_NAME := ppanyukov

.PHONY: all
all:
	cd dockerfiles/vso-agent && $(MAKE) all

.PHONY: clean
clean:
	cd dockerfiles/vso-agent && $(MAKE) clean

.PHONY: push_hub
push_hub:
	cd dockerfiles/vso-agent && $(MAKE) push_hub

