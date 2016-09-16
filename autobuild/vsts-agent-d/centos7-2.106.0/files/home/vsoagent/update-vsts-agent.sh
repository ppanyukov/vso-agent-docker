#!/usr/bin/env bash

# Checks if a new release for VSTS agent is available.
# If so, downloads and replaces the agent bundled with the image.
#
# This is to solve the problem with forced agent auto-updates where the
# running agent would trigger an update and restart, which then kills the
# running container. This start-update-stop-start chain would then continue
# forever.
#
# Run this before starting the agent.
#
# See https://github.com/Microsoft/vsts-agent/issues/410#issuecomment-234524601
#
# IMPORTANT. Run as vsoagent user using:
#   su --login vsoagent -c "/volumes/update-vsts-agent.sh"
# or
#   su --login ${z_user_name} -c "/volumes/update-vsts-agent.sh"
#
#
# To avoid downloading things every time, map /home/vsoagent/downloads as a volume.
# The script will check if the requried file is already there and use that
# rather than downloading from scratch.

set -e
set +x

# First, get the version of the latest release.
# The response to https://github.com/Microsoft/vsts-agent/releases/latest
# will containe Location header with the latest version like this:
#   https://github.com/Microsoft/vsts-agent/releases/download/v2.104.0
#
# We want to extract `2.104.0` bit.
#
# Make sure to remove the \r\n! Otherwise this would cause massive issues.
# Get rid of leading `v` too.
#
echo "Checking for the latest version of VSTS agent."
VSTS_LATEST_VERSION=$(curl -I https://github.com/Microsoft/vsts-agent/releases/latest \
    | grep 'Location:' \
    | awk -F "/" '{print $NF}' \
    | tr -d 'v\r\n'
)

# The image will have env var z_vsts_agent_version specifying the version
# bundled with the image. If the latest version is not same as bundled,
# initiate the upgrate before we start

if test "X${VSTS_LATEST_VERSION}" == "X${z_vsts_agent_version}"
then
    echo "The latest agent version ${VSTS_LATEST_VERSION} is same as bundled ${z_vsts_agent_version}."
    echo "No need to upgrade."
    exit 0
fi


echo "The latest agent version ${VSTS_LATEST_VERSION} is not same as bundled ${z_vsts_agent_version}."
echo "Will perform upgrade."

# OK, upgrade is required. All operations will happen from vso agent home dir
pushd ${z_user_home} >/dev/null

VSTS_TAR_NAME="vsts-agent-rhel.7.2-x64-${VSTS_LATEST_VERSION}.tar.gz"
VSTS_LATEST_URL="https://github.com/Microsoft/vsts-agent/releases/download/v${VSTS_LATEST_VERSION}/${VSTS_TAR_NAME}"


DOWNLOAD_DIR="${z_user_home}/downloads"
mkdir -p ${DOWNLOAD_DIR}

if test ! -f "${DOWNLOAD_DIR}/${VSTS_TAR_NAME}"
then
    echo "Will download from ${VSTS_LATEST_URL}"
    curl -L -o "${DOWNLOAD_DIR}/${VSTS_TAR_NAME}" ${VSTS_LATEST_URL}
    echo "Download complete:"
    ls -lh "${DOWNLOAD_DIR}/${VSTS_TAR_NAME}"
fi

echo "Downloaded agent ${VSTS_TAR_NAME} already exists, copying..."
cp "${DOWNLOAD_DIR}/${VSTS_TAR_NAME}" "./${VSTS_TAR_NAME}"
echo "Done copying"

echo "Unpacking"
tar -zxf ./${VSTS_TAR_NAME}
rm -f ./${VSTS_TAR_NAME}

echo "The update is complete."
