# Builds the docker images

.PHONY: all
all:
	cd dockerfiles/vso-agent && $(MAKE) all

.PHONY: clean
clean:
	cd dockerfiles/vso-agent && $(MAKE) clean

