#!/usr/bin/env bash

# For local builds and test runs

# Default image tag to build/run
if test "X${IMAGE_TAG}" = "X"
then
    IMAGE_TAG="centos7-dev"
fi

pushd $(dirname $0)/${IMAGE_TAG} &>/dev/null


IMAGE_NAME="ppanyukov/vsts-agent-d:${IMAGE_TAG}"
CONTAINER_NAME="vsts-agent-d.${IMAGE_TAG}"
DIR=.
ARG0=$0
ARG1=$1
ARG2=$2


# Credentials and stuff read from here
VSTS_AGENT_SETTINGS_FILE="${HOME}/.vsts-agent/vsts.settings"

function check_is_running {
    docker inspect -f {{.State.Running}} $CONTAINER_NAME &> /dev/null
    echo $?
}

function do_start {
    # interactive startup if second arg is -i
    local flags="-d --restart=always"

    if test "X${ARG2}" = "X-i"
    then
        flags="-it --rm"
    fi

    echo "Starting image ${IMAGE_NAME} to run with name ${CONTAINER_NAME} with flags: ${flags}."

    # VSTS_ vars come from this file
    if test -f ${VSTS_AGENT_SETTINGS_FILE}
    then
        . ${VSTS_AGENT_SETTINGS_FILE}
    fi

    docker run \
        ${flags} \
        --name=${CONTAINER_NAME} \
        -e VSTS_AGENT_NAME_PREFIX="${VSTS_AGENT_NAME_PREFIX}" \
        -e VSTS_AUTH_TYPE="${VSTS_AUTH_TYPE}" \
        -e VSTS_AUTH_TOKEN="${VSTS_AUTH_TOKEN}" \
        -e VSTS_POOL="${VSTS_POOL}" \
        -e VSTS_URL="${VSTS_URL}" \
        -v $(pwd)/${DIR}/_diag:/home/vsoagent/_diag \
        -v $(pwd)/${DIR}/_work:/home/vsoagent/_work \
        ${IMAGE_NAME} \
        /usr/bin/bash -c "
            exec ./run-vsts-agent-d.sh \\
            1>>/home/vsoagent/_diag/stdout.log 2>>/home/vsoagent/_diag/stderr.log
        "

}

function do_kill_no_fail {
    docker stop ${CONTAINER_NAME} &>/dev/null || true
    docker rm ${CONTAINER_NAME} &>/dev/null || true
}

function do_build {
    docker build --tag ${IMAGE_NAME} ${DIR}
}

function usage {
cat << EOF
Usage: $(basename $ARG0) {build|start|stop|restart|try-restart|force-reload|status} {-i}

The -i specifies to run in foreground interactively.
EOF
}

case "$1" in
build)
    do_build
    ;;
start)
    is_running=$(check_is_running)
    if test "X${is_running}" = "X0"
    then
        echo "The image ${IMAGE_NAME} is already running with name ${CONTAINER_NAME}."
        exit 0
    fi
    do_kill_no_fail
    do_start
    ;;
stop)
    do_kill_no_fail
    ;;
restart|force-reload)
    do_kill_no_fail
    do_start
    ;;
try-restart)
    do_kill_no_fail
    do_start
    ;;
reload)
    do_kill_no_fail
    do_start
    ;;
help|h|usage)
    usage
    ;;
status)
    is_running=$(check_is_running)
    if test "X${is_running}" = "X0"
    then
        echo "The image ${IMAGE_NAME} is already running with name ${CONTAINER_NAME}."
        exit 0
    else
        echo "The image ${IMAGE_NAME} is not running."
        exit 1
    fi
    ;;
*)
    usage
    exit 1
    ;;
esac

