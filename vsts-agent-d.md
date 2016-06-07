# VSTS agent D

Image built on top of base `vsts-agent` to run in unattended
mode on VMs and on clusters, with several features and enhancements
required to support this.

Pre-built docker images: https://hub.docker.com/r/ppanyukov/vsts-agent-d-auto/tags/

Briefly:

- fully parameterised VSTS configuration (credentials, etc)

- supports daemonised and interactive modes of running

- graceful restarts in case of crashes 
  (e.g. with `docker run -d --restart=always`)

- agent naming to aid identification in VSO pools

- agent naming to have predictable ordering in the pool

- correct handling of SIGTERM

- removal of agent registration from VSO on stop


# How to run this image

## Step 0: Set some env vars

```
VSTS_AGENT_IMAGE_TAG="ppanyukov/vsts-agent-d-auto:dev"
VSTS_AGENT_SETTINGS_FILE="~/.vsts-agent/vsts.settings"
```

## Step 1: Create VSTS settings file

This will make things easier.

On the host, do:

```
mkdir -p $(dirname ${VSTS_AGENT_SETTINGS_FILE})

# Obviously supply correct values here...
cat << EOF > ${VSTS_AGENT_SETTINGS_FILE}
VSTS_AGENT_NAME_PREFIX="some_prefix"
VSTS_AUTH_TYPE="PAT"
VSTS_AUTH_TOKEN="your auth token"
VSTS_POOL="name of the agent pool in VSO"
VSTS_URL="https://company.visualstudio.com"
EOF 

```

## Step 2: Build or pull the image


### Build the image

```
docker build --tag ${VSTS_AGENT_IMAGE_TAG} .
```

### Pull the image

```
docker pull ${VSTS_AGENT_IMAGE_TAG}
```


## Step 3: Run the agent – interactively

```
# make credentials available as env vars
. ${VSTS_AGENT_SETTINGS_FILE}

docker run \
    -it \
    --rm \
    -e VSTS_AGENT_NAME_PREFIX="${VSTS_AGENT_NAME_PREFIX}" \
    -e VSTS_AUTH_TYPE="${VSTS_AUTH_TYPE}" \
    -e VSTS_AUTH_TOKEN="${VSTS_AUTH_TOKEN}" \
    -e VSTS_POOL="${VSTS_POOL}" \
    -e VSTS_URL="${VSTS_URL}" \
    ${VSTS_AGENT_IMAGE_TAG}
```

To stop the agent:

Press `CTRL-C`. This will terminate the agent, turn it red in VSO and 
unregister it from VSO.



## Step 4: Run the agent – daemonised

```
# make credentials available as env vars
. ${VSTS_AGENT_SETTINGS_FILE}

CONTAINER_NAME=$(docker run \
    -d \
    --restart=always \
    -e VSTS_AGENT_NAME_PREFIX="${VSTS_AGENT_NAME_PREFIX}" \
    -e VSTS_AUTH_TYPE="${VSTS_AUTH_TYPE}" \
    -e VSTS_AUTH_TOKEN="${VSTS_AUTH_TOKEN}" \
    -e VSTS_POOL="${VSTS_POOL}" \
    -e VSTS_URL="${VSTS_URL}" \
    ${VSTS_AGENT_IMAGE_TAG})
```


To stop the agent:

```
docker stop ${CONTAINER_NAME}
```

This will terminate the agent, turn it red in VSO and unregister it
from VSO.


The same container can be started again:

```
docker start ${CONTAINER_NAME}
```

This will register new agent with VSO.


Using `--restart` option with daemonised mode.
If the agent crashes for some reason, docker will restart
the container. This will create new agent registration in 
the agent pool in VSO.


