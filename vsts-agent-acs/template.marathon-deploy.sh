#!/usr/bin/env bash

set -e

DIR=$(dirname $0)
MANIFEST=${DIR}/marathon.json
MARATHON_URI=http://localhost/marathon/v2


cat << EOF
------------------------------------------------------------------------------
NOTE:

This will deploy VSTS agent to run on ACS with Marathon.

The details of deployment:

    - Marathon URI: ${MARATHON_URI}
    - Application manifest: ${MANIFEST}

There are no secrets in this file.

Do not share application manifest ${MANIFEST}
as it contains secrets.

------------------------------------------------------------------------------

TUNNEL TO ACS:

The marathon URI here is assumed to be as set up using ACS with DCOS
templates. For this to work, establish ssh tunnel to the ACS master, e.g:

Add these lines to ~/.ssh/config:

    Host acs-tunnel
        HostName <YOUR_ACS_MASTER_HOSTNAME>
        User <YOUR_USER>
        IdentityFile <PATH_TO_PRIVATE_SSH_KEY>
        Port 2200
        LocalForward 80 localhost:80

After that create tunnel like this:

    sudo ssh -F ~/.ssh/config acs-tunnel

------------------------------------------------------------------------------

EOF

if test "X$1" = "Xhelp"
then
    exit 0
fi

curl -i -X PUT -H 'Content-Type: application/json' \
    ${MARATHON_URI}/apps/%MARATHON_ID% --data @${MANIFEST}

# add newline
echo
