#!/usr/bin/env bash

# Wrapper script to be run within the container to configure and launch
# VSTS agent.
#
# See comments throughout the script to see what and why.

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
    - security features around credentials handling

For full list of features and docs see https://github.com/ppanyukov/vso-agent-docker

EOF
}

# Cleanly terminates background jobs (including VSTS agent)
function clean_up {
    echo "Invoking clean-up script"

    # VSTS agent does not respond to SIGTERM (yet), see:
    # https://github.com/Microsoft/vsts-agent/issues/215
    #
    # Until this is in release, it needs SIGINT
    JOBS=$(pgrep -u ${z_user_name})
    echo "Child PIDs to kill: ${JOBS}"
    ps -f ${JOBS}
    kill -s SIGINT ${JOBS}

    sleep 2s

    # This should unregister the agent from VSO
    # We now need to supply the auth token we used during registration as
    # the agent no longer keeps this around.
    # See: https://github.com/Microsoft/vsts-agent/issues/403
    echo "Removing agent from VSO"    
    ./bin/Agent.Listener remove --unattended --auth "${VSTS_AUTH_TYPE}" --token "${VSTS_AUTH_TOKEN}"

    # Feature: security
    # Just make sure credentials are zapped.
    # Even though these credentials may no longer be super-sensitive, not reason
    # to leave them floating around.
    rm -f .credentials .credentials_rsaparams

    # See http://veithen.github.io/2014/11/16/sigterm-propagation.html
    # for why we use wait here.
    echo "DONE CLEANUP, waiting for all child processes to go away"
    wait
    echo "ALL DONE, exiting"
}

function run {

    # Feature: security
    #
    # Make effort to secure the credendials so that they cannot be obtained
    # easily by crafting build tasks run by the agent or via UI in VSO:
    #
    #   - using /proc/PID/environ
    #   - using /bin/env command
    #   - using .credentials file created by agent registration (plain text)
    #   - using ps -ef (e.g. we can't start agent with secret tokens on command line).
    #
    # The approach is this:
    #
    #   - wrapper script runs as root
    #
    #   - it ensures the VSTS_ vars are not exported to child agent process
    #
    #   - it performs agent startup in two steps:
    #       - registration: this write stuff to .credentials
    #       - running: agent is started without giving credentials at command line.
    #
    #   - agent is started as non-priviledged user
    #
    #   - on shutdown we zap .credentials just to make sure.
    #
    #
    # How this solves the problem:
    #
    #   - the build tasks will not be able to read /proc/1/environ where the
    #     VSTS_ vars will be present because this will be owned by root.
    #
    #   - running ps -ef will not reveal VSTS_ vars because we don't start
    #     agent with command line params
    #
    #   - running /bin/env as one of the build tasks is safe because we will
    #     not export VSTS_ vars to child processes
    #
    #   - similarly VSTS_ vars will not be exposed as capabilities in VSO
    #     because we do not make these available as env vars to the agent process
    #
    # The implementation is spread around in this file with relevant comments
    # where appropriate.
    #
    # NOTE on .credentials files:
    #   - unfortunately we can no longer employ the "delete credentials once
    #     the agent starts" solution because the agent requires files 
    #     .credentials_rsaparams file when executing the build.
    #     The contents of this file is not as sensitive as before but is still
    #     not 100% secure.
    #     
    #     The change is in RTM release of v2.103.0 where a lot of work on
    #     security was done.
    #
    #     For details of what these files are see here:
    #     https://github.com/Microsoft/vsts-agent/issues/402


    # Feature: security.
    # Ensure we are running as root as we rely on this to secure agent env.
    if test "${UID}" != "0"
    then
        echo "ERROR: $0: this script must be run as root."
        exit 1
    fi

    # Feature: security
    # Prevent export of VSTS_ vars to child processes.
    local SEC_VARS=$(env | grep VSTS_ | cut -f1 -d=)
    export -n ${SEC_VARS} DUMMY

    # Feature: security.
    # Run agent as ordinary user with su.
    #
    # NOTE: using --session-command to enable clean shutdown when using CTRL-C
    # in interactive mode, which does not work if we use -c.
    # See: http://sethmiller.org/it/su-forking-and-the-incorrect-trapping-of-sigint-ctrl-c/
    #
    # NOTE: z_ vars are predefined in the base image.
    local SUCMD="su -g ${z_user_group_name} --session-command"
    local SUID="${z_user_name}"


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


    # Workaround: avoid infinite stop-start loops due to agent auto-update.
    # Perform agent update before starting.
    ${SUCMD} "${z_user_home}/update-vsts-agent.sh" ${SUID}

    # Feature: Reliable restart for 'docker run -d --restart=always' 
    # in this scenario:
    #
    #   - Start agent in daemonised mode with --restart=always
    #   - In VSO manually delete the agent from the pool
    #   - The running agent will crash
    #   - Docker will restart the agent but it will not be
    #     able to start.
    #   - Docker will keep restarting forever and never succeed.
    #
    # The fix is to always delete agent registration kept in .agent.
    # and perform fresh registration every time we run this script.
    # Because we also remove the agent from VSO on clean stop this should
    # not cause pool filling up with dead agents in most cases.
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
    # delete .agent file and retry?
    #
    #
    rm -f .agent

    # Feature: good predictable agent naming.
    #
    # Agent names must be unique in VSO.
    # We also want them recognisable.
    # We also want agents show up in order of registration in VSO.
    #
    # Solution:
    #   - UUID for agent name
    #   - Use VSTS_AGENT_NAME_PREFIX pre prefix the agent with predefined string,
    #     e.g. myagent.
    #   - Use date-time after agent prefix to make agents show up in order of
    #     registration since UUID is random.
    #   - Observe restriction of 64 chars for agent names.
    #
    local DATE=$(date +"%Y%m%d-%H%M%S")
    local VSTS_AGENT_NAME=$(echo "${VSTS_AGENT_NAME_PREFIX}.${DATE}.$(uuidgen)" | cut -c1-64)

    # Feature: clean shutdown and unregister from vso.
    # Cleanup hook
    trap clean_up HUP INT QUIT TERM

    # Feature: security
    # Two-phased start: config then run, both run with su.
    #
    # This saves the configuration in a file.
    echo "Configuring VSTS agent..."
    ${SUCMD} "exec ./bin/Agent.Listener \
        configure \
        --unattended \
        --nostart \
        --agent ${VSTS_AGENT_NAME} \
        --auth ${VSTS_AUTH_TYPE} \
        --token ${VSTS_AUTH_TOKEN} \
        --pool ${VSTS_POOL} \
        --url ${VSTS_URL} \
        --acceptteeeula Y" \
    ${SUID}

    # This actually runs the agent.
    echo "Running VSTS agent..."
    ${SUCMD} "exec ./bin/Agent.Listener --unattended" ${SUID} &

    echo "Running the agent in background"

    # This will wait for the termination of all child processes.
    # Need to also wait in clean_up due to how bash works.
    # See: http://veithen.github.io/2014/11/16/sigterm-propagation.html
    wait
}

run

