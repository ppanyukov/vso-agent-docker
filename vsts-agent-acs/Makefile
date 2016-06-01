BASE_IMAGE_TAG := 'ppanyukov/vsts-agent-auto:centos7-preview-2.101.0'
IMAGE_TAG := ppanyukov/vsts-agent-acs:dev

# VSTS settings files, defaults and user-supplied
# The user-supplied file does not have to exist
DEFAULT_VSTS_SETTINGS := vsts.settings marathon.settings
USER_VSTS_SETTINGS := ~/.vsts-agent-acs/vsts.settings ~/.vsts-agent-acs/marathon.settings

# intermediate build artifacts will go here
WORKDIR := _work/
OUT_DOCKERFILE := $(WORKDIR)Dockerfile
OUT_MARATHON_JSON := $(WORKDIR)marathon.json

# template files and their corresponding generated files
TEMPLATE_FILES := $(wildcard template.*)
GENERATED_FILES := $(patsubst template.%, $(WORKDIR)%, $(TEMPLATE_FILES))
.PHONY: $(GENERATED_FILES)


# Do not fail if the user-supplied settings file does not exist
include $(DEFAULT_VSTS_SETTINGS)
-include $(USER_VSTS_SETTINGS)

.PHONY: help all templates clean push agent_image $(OUT_DOCKERFILE) $(OUT_MARATHON_JSON)

help:
	@echo " Builds VSTS agent docker image and marathon json manifest"
	@echo ""
	@echo " To use this makefile:"
	@echo ""
	@echo "    - make all: to build the agent image and generate marathon manifest"
	@echo "    - make templates: generate all files from templates"
	@echo "    - make push: to push the agent image to docker hub"
	@echo "    - make clean: delete generated artifacts"
	@echo ""
	@echo " Additional targets:"
	@echo ""
	@echo "    - make agent_image: to build just the agent image locally"
	@echo "    - make $(OUT_DOCKERFILE): to generate Dockerfile from template"
	@echo "    - make $(OUT_MARATHON_JSON): to generate marathon manifest file"
	@echo ""
	@echo ""
	@echo " VSTS credentials for marathon etc:"
	@echo ""
	@echo "    - to actually run the agent it needs to be configured with credentials"
	@echo "    - these can be provided in '$(USER_VSTS_SETTINGS)'"
	@echo "    - this makefile will automatically pick it up"
	@echo "    - the values from '$(USER_VSTS_SETTINGS)' will be used to replace"
	@echo "      tokens in various other files"
	@echo "    - for the list of settings see "


# Almost all, excluding pushing and deployments
all: templates agent_image
	@echo " ============================="
	@echo "    The agent image is built locally."
	@echo ""
	@echo "     Next steps:"
	@echo "         - push to docker hub: make push"
	@echo ""
	@echo "    Generated artifacts: $(GENERATED_FILES)"
	@echo "        - agent image Dockerfile: $(OUT_DOCKERFILE)"
	@echo "        - marathon json manifest: $(OUT_MARATHON_JSON)"


# Generate all files from templates
templates: $(GENERATED_FILES)


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


# Replace placeholders in any template.<filename> file and write to $(WORKDIR)/<filename>
$(GENERATED_FILES): $(WORKDIR)%: template.%

	@echo -----------------------------------------
	@echo Generating $@ from $< tempalate
	@mkdir -p $(WORKDIR)
	@cp $< $@.tmp # to preserve permissions etc
	@sed \
		-e 's#%BASE_IMAGE_TAG%#$(BASE_IMAGE_TAG)#g' \
		-e 's#%IMAGE_TAG%#$(IMAGE_TAG)#g' \
		-e 's#%VSTS_AGENT_NAME_PREFIX%#$(VSTS_AGENT_NAME_PREFIX)#g' \
		-e 's#%VSTS_AUTH_TYPE%#$(VSTS_AUTH_TYPE)#g' \
		-e 's#%VSTS_AUTH_TOKEN%#$(VSTS_AUTH_TOKEN)#g' \
		-e 's#%VSTS_POOL%#$(VSTS_POOL)#g' \
		-e 's#%VSTS_URL%#$(VSTS_URL)#g' \
		-e 's#%MARATHON_ID%#$(MARATHON_ID)#g' \
		-e 's#%MARATHON_INSTANCES%#$(MARATHON_INSTANCES)#g' \
		-e 's#%MARATHON_VERSION%#$(MARATHON_VERSION)#g' \
		$< > $@.tmp
	@mv $@.tmp $@
	@echo -----------------------------------------



