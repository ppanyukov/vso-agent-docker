BASE_IMAGE_TAG := 'ppanyukov/vsts-agent-auto:centos7-preview-2.101.0'
IMAGE_TAG := ppanyukov/vsts-agent-acs3:dev

.PHONY: clean all push

Dockerfile: template.Dockerfile
	sed \
		-e 's#%BASE_IMAGE_TAG%#$(BASE_IMAGE_TAG)#g' \
		$< > $@.tmp
	mv $@.tmp $@

clean:
	-rm -rf Dockerfile

all: Dockerfile
	docker pull $(BASE_IMAGE_TAG)
	docker build --tag $(IMAGE_TAG) .
	@echo Built image $(IMAGE_TAG)

push: all
	docker push $(IMAGE_TAG)

