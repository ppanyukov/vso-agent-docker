#!/usr/bin/env bash

# Wrapper script to be run within the container to configure and launch
# VSTS agent.
#
# Runs VSTS image in docker container in unattended daemonised mode.
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

Some features:

    - sane and predictable agent naming which works with restarts
    - correct handling of SIGTERM
    - unregisters the agent from VSO when it stops via SIGTERM (best effort)
    - maskig of VSTS_ environment variables
    - suitable for running on clusters (ACS/Mesos/DCOS)

For full list of features and docs see docs at: https://github.com/ppanyukov/vso-agent-docker

EOF
}

# Cleanly terminates background jobs (including VSTS agent)
function clean_up {
    # Until agent handles SIGTERM correctly, it needs SIGINT
    echo "Invoking clean-up script"
    # all the rest plain kill, no fail
    JOBS=$(jobs -p)
    echo "Child PIDs to kill: ${JOBS}"
    kill -s SIGINT ${JOBS}

    # This should unregister the agent from VSO
    # Hopefully removes the need for sleep?
    echo "Removing agent from VSO"
    ./bin/Agent.Listener unconfigure --unattended

    # Normally we would need to sleep for a bit after sending SIGING to the
    # agent, but this does not seem to be required if we do the unconfigure.
    # sleep 3s

    echo "DONE CLEANUP"
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


    # Feature: Reliable restart for 'docker run -d --restart=always' 
    # in this scenario:
    #
    #   - Start agent in daemonised mode with --restart=always
    #   - In VSO manuall delete the agent from the pool
    #   - The running agent will crash
    #   - Docker will restart the agent but it will not be
    #     able to start.
    #   - Docker will keep restarting forever and never succeeding.
    #
    # The fix is to always delete agent registration kept in .Agent.
    # and perform fresh registration every time we run this script.
    # Because we also remove the agent from VSO on stop this should
    # not cause pool filling up with dead agents.
    #
    # Such behaviour also has benefits:
    #
    #   - consistent behaviour with Mesos/ACS/Marathon when
    #     restarting agents there.
    #
    #   - very simple rules: you run the script, you get new
    #     registration
    #
    #
    # TODO(ppanyukov): consider more clever way of doing this, e.g
    # try registration or running, if any of them fail then
    # delete .Agent file and retry?
    #
    #
    rm -rf .Agent

    # Agent names can't exceed 64 chars
    # Emded timstamp to give predictable order to agent names
    DATE=$(date +"%Y%m%d-%H%M%S")
    local VSTS_AGENT_NAME=$(echo "${VSTS_AGENT_NAME_PREFIX}.${DATE}.$(uuidgen)" | cut -c1-64)

    # Make sure these are not published as capabilities
    export VSO_AGENT_IGNORE="VSTS_AGENT_NAME_PREFIX,VSTS_AUTH_TYPE,VSTS_AUTH_TOKEN,VSTS_POOL,VSTS_URL,VSTS_AGENT_NAME"

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

    # Once the agent is configured, we can unset the VSTS_ vars
    # TODO(ppanyukov): unset VSTS_ vars in reliable manner.

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

