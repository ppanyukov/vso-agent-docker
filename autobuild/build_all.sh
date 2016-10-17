#!/usr/bin/env bash

# Build all recent images

set -e

tags="
    centos7-2.106.0 
    centos7-2.107.1 
    centos7-latest 
    latest
"

function build_images {
    local image_dir=$1
    local image_name=$2

    for tag in ${tags}
    do
        (
            cd $(dirname ${BASH_SOURCE})/${image_dir}/${tag}
            full_image_name="${image_name}:${tag}"
            echo "Building ${full_image_name} from ${PWD}"
            docker build --rm --tag ${full_image_name} .
            echo "DONE: Building ${full_image_name} from ${PWD}"
        )
    done
}

function build_all {
    docker pull centos:centos7
    build_images "vsts-agent" "ppanyukov/vsts-agent-auto"
    build_images "vsts-agent-d" "ppanyukov/vsts-agent-d"

    docker images | grep -e 'ppanyukov/vsts-agent-auto' -e 'ppanyukov/vsts-agent-d'
}

build_all