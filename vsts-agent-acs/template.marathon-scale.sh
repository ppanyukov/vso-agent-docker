#!/usr/bin/env bash

set -e

MARATHON_URI=http://localhost/marathon/v2
MARATHON_ID=%MARATHON_ID%
MARATHON_INSTANCES=%MARATHON_INSTANCES%

INSTANCES=$1
if test "X${INSTANCES}" = "X"
then
    INSTANCES=${MARATHON_INSTANCES}
fi

cat << EOF
------------------------------------------------------------------------------
NOTE:

This will scale on VSTS agent on ACS.

By default will scale to ${MARATHON_INSTANCES} which is
the same as in the deployment manifest.

To scale to any required number use:

    $(basename $0) INSTANCES

For example:

    $(basename $0) 3

Details:

    - ACS Marathon URI: ${MARATHON_URI}
    - Marathon App ID: ${MARATHON_ID}
    - Instances: ${INSTANCES}

------------------------------------------------------------------------------

EOF

if test "X$1" = "Xhelp"
then
    exit 0
fi


# TODO(ppanyukov): generating JSON like this feels dirty
curl -i \
    ${MARATHON_URI}/apps/${MARATHON_ID} \
    -X PUT \
    -H 'content-type: application/json' \
    --data-binary "{\"instances\":${INSTANCES}}" \
    --compressed

# add newline
echo
