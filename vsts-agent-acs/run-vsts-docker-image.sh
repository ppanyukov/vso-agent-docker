#!/usr/bin/env bash

# Runs VSTS image in docker container in unattended daemonised mode.
# For running on ACS/Mesos with Marathon.
# 

set -e

function usage {
    cat << EOF
$(basename $0): Runs VSTS agent in unattended manner.

Usage: the following environmental variables must be set:

    - VSTS_AGENT_NAME_PREFIX
    - VSTS_AUTH_TYPE
    - VSTS_AUTH_TOKEN
    - VSTS_POOL
    - VSTS_URL

Example:

    env \\
        VSTS_AGENT_NAME_PREFIX="some_prefix" \\
        VSTS_AUTH_TYPE="PAT" \\
        VSTS_AUTH_TOKEN="4ji744afn..." \\
        VSTS_POOL="Name of agent pool" \\
        VSTS_URL="https://company.visualstudio.com" \\
        $0


Example: Running in docker container

    docker run \\
        -d \\
        -e VSTS_AGENT_NAME_PREFIX="some_prefix" \\
        -e VSTS_AUTH_TYPE="PAT" \\
        -e VSTS_AUTH_TOKEN="4ji744afn..." \\
        -e VSTS_POOL="Name of agent pool" \\
        -e VSTS_URL="https://company.visualstudio.com" \\
        DOCKER_IMAGE_NAME

EOF
}

# Cleanly terminates background jobs (including VSTS agent)
function clean_up {
    # Assume %1 is the vso agent, it needs SIGQUIT
    echo "Invoking clean-up scrip"
    # all the rest plain kill, no fail
    J=$(jobs -p)
    echo "PIDs to kill: ${J}"
    kill -s SIGINT ${J}

    # This should unregister the agent from VSO
    # Hopefully removes the need for sleep?
    echo "Removing agent from VSO"
    ./bin/Agent.Listener unconfigure --unattended

    # Somehow must have this sleep to get the agent to report to
    # VSO it is dead. Is 3 secs enough?
    # sleep 3s

    echo DONE CLEANUP
}

function run {

    # Require these env variables to be set:
    if test "X${VSTS_AGENT_NAME_PREFIX}" = "X" || \
       test "X${VSTS_AUTH_TYPE}" = "X" || \
       test "X${VSTS_AUTH_TOKEN}" = "X" || \
       test "X${VSTS_POOL}" = "X" || \
       test "X${VSTS_URL}" = "X"
    then
        echo "ERROR: Need to specify all required environmental variables."
        echo ""
        usage
        exit -1
    fi


    # Agent names can't exceed 64 chars
    # Emded timstamp to give predictable order to agent names
    DATE=$(date +"%Y%m%d-%H%M%S")
    local VSTS_AGENT_NAME=$(echo "${VSTS_AGENT_NAME_PREFIX}.${DATE}.$(uuidgen)" | cut -c1-64)


    # Make sure these are not published as capabilities
    export VSO_AGENT_IGNORE="VSTS_AGENT_NAME_PREFIX,VSTS_AUTH_TYPE,VSTS_AUTH_TOKEN,VSTS_POOL,VSTS_URL,VSTS_AGENT_NAME"


    # Capabilities whould be exported as CAP_${some_capability}.
    export CAP_VSTS_TEST="some_capability"


    # This saves the configuration in a file.
    echo "Configuring VSTS agent..."
    ./bin/Agent.Listener \
        configure \
        --unattended \
        --nostart \
        --agent ${VSTS_AGENT_NAME} \
        --auth ${VSTS_AUTH_TYPE} \
        --token ${VSTS_AUTH_TOKEN} \
        --pool ${VSTS_POOL} \
        --url ${VSTS_URL} \
        --acceptteeeula Y

    # This actually runs the agent.
    echo "Running VSTS agent..."
    # Run in background. Trap SIGTERM SIGINT SIGQUIT and kill that background job
    # This is a workaround for agent not responding to SIGTERM at the mo.

    # Cleanup hook
    trap clean_up HUP INT QUIT TERM

    ./bin/Agent.Listener \
        --unattended &

    echo "Running the agent in background"
    wait
}


run

