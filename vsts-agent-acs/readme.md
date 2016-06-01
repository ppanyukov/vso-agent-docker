Hacky hacks around making VSTS agent work in Azure Container Services
with Mesos and Marathon. Manual build for now.


### To build:

```
# Build VSTS image:
make all

# Build VSTS image and push to docker hub
make push

# Generate manifests and scripts
make templates

```


### To run

Interactively with local docker:

```
    make all
    _work/run-image.sh
```


On ACS with marathon:

```
    make all

    # then use _work/marathon.json to deploy to marathon
```


### More build info

For full build details run 

```
    make help
```
