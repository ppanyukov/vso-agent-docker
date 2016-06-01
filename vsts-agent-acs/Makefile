BASE_IMAGE_TAG := 'ppanyukov/vsts-agent-auto:centos7-preview-2.101.0'
IMAGE_TAG := ppanyukov/vsts-agent-acs:dev


# intermediate build artifacts will go here
WORKDIR := _work/
OUT_DOCKERFILE := $(WORKDIR)Dockerfile
OUT_MARATHON_JSON := $(WORKDIR)marathon.json

.PHONY: help all clean push agent_image $(OUT_DOCKERFILE) $(OUT_MARATHON_JSON)

help:
	@echo " Builds VSTS agent docker image and marathon json manifest"
	@echo ""
	@echo " To use this makefile:"
	@echo ""
	@echo "	- make all: to build the agent image and generate marathon manifest"
	@echo "	- make push: to push the agent image to docker hub"
	@echo "	- make clean: delete generated artifacts"
	@echo ""
	@echo " Additional targets:"
	@echo ""
	@echo "	- make agent_image: to build just the agent image locally"
	@echo "	- make $(OUT_DOCKERFILE): to generate Dockerfile from template"
	@echo "	- make $(OUT_MARATHON_JSON): to generate marathon manifest file"
	@echo ""


# Almost all, excluding pushing and deployments
all: agent_image $(OUT_MARATHON_JSON)
	@echo " ============================="
	@echo " The agent image is built locally."
	@echo ""
	@echo " 	Next steps:"
	@echo " 		- push to docker hub: make push"
	@echo ""
	@echo " 	Generated artifacts:"
	@echo "		- agent image Dockerfile: $(OUT_DOCKERFILE)"
	@echo " 		- marathon json manifest: $(OUT_MARATHON_JSON)"



# Zap all built artifacts
clean:
	-rm -rf $(WORKDIR)


# Push
push: agent_image
	docker push $(IMAGE_TAG)


# ================================
# Other targets
# ================================

# Builds the docker image for the agent
agent_image: $(OUT_DOCKERFILE)
	@echo Building docker image for the agent tagged $(IMAGE_TAG)

	@echo - Pulling base image $(BASE_IMAGE_TAG)
	docker pull $(BASE_IMAGE_TAG)

	@echo - Bulding the image from Dockerfile
	docker build --tag $(IMAGE_TAG) -f $(WORKDIR)Dockerfile .

	@echo - DONE: Built image $(IMAGE_TAG)


# Generate agent docker file from template
$(OUT_DOCKERFILE): template.Dockerfile
	@echo Generating agent image Dockerfile from template $<

	mkdir -p $(WORKDIR)
	sed \
		-e 's#%BASE_IMAGE_TAG%#$(BASE_IMAGE_TAG)#g' \
		$< > $@.tmp
	mv $@.tmp $@



# Generate marathon json application manifest from template
# TODO(ppanyukov): VSTS credentials etc embedded there.
$(OUT_MARATHON_JSON): template.marathon.json
	mkdir -p $(WORKDIR)
	sed \
		-e 's#%IMAGE_TAG%#$(IMAGE_TAG)#g' \
		$< > $@.tmp
	mv $@.tmp $@


