#!/usr/bin/env bash

set -e

cat << EOF
------------------------------------------------------------------------------
NOTE:

    This will run VSTS agent docker image 

        '%IMAGE_TAG%' 

    in a daemonised mode using local docker.
    
    The VSTS credentials are prepopulated.
    
    Do not share this file.
------------------------------------------------------------------------------
EOF

docker run \
    -d \
    --restart=on-failure:3 \
    -e VSTS_AGENT_NAME_PREFIX="%VSTS_AGENT_NAME_PREFIX%.${HOSTNAME}" \
    -e VSTS_AUTH_TYPE="%VSTS_AUTH_TYPE%" \
    -e VSTS_AUTH_TOKEN="%VSTS_AUTH_TOKEN%" \
    -e VSTS_POOL="%VSTS_POOL%" \
    -e VSTS_URL="%VSTS_URL%" \
    %IMAGE_TAG%
