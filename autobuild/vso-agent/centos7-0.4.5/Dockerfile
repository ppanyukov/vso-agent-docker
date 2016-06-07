#
# Docker file for building VSO xplat agent running on CentOS 7
# as provided by Microsoft here: https://github.com/Microsoft/vso-agent
#
# This version downloads uses an installer bash script
# rather than downloaded a release tar.gz from github because
# there are no releases of this version there.
#
# This version is for the older installations which are still
# in use in some environments.
#
# The file files/xplatagent_install.sh is obtained using
# curl -skSL http://aka.ms/xplatagent.  It is as a copy to
# prevent any unexpected changes to it in the future.
#
# This file if for automated docker hub builds.
#

FROM centos:centos7
MAINTAINER ppanyukov@googlemail.com

ENV \
    z_user_name=vsoagent  \
    z_user_group_name=vsoagent \
    z_user_uid=1000 \
    z_user_gid=1000 \
    z_user_home=/home/vsoagent


# Create group and user for VSO agent
# and add RPMs needed by xplat installer.
# Git is required for pulling sources from VSO obviously.
RUN echo "" \
    && echo "Creating user and group" \
    && groupadd -g ${z_user_gid} ${z_user_group_name} \
    && useradd \
    --create-home \
    --home-dir ${z_user_home} \
    --gid ${z_user_group_name}  \
    --no-user-group  \
    --uid ${z_user_uid} ${z_user_name} \
    && echo "- Adding prerequisite RPMs" \
    && yum -y install \
        git \
        wget \
        which \
        unzip


USER ${z_user_name}
WORKDIR ${z_user_home}


ENV \
    z_vso_agent_version=0.4.5 

COPY files/xplatagent_install.sh ${z_user_home}/xplatagent_install.sh

# Install the thing
RUN echo "" \
    && echo "Running xplatagent_install.sh" \
    && GET_AGENT_VERSION="@${z_vso_agent_version}" \
        GET_NODE_VERSION="5.6.0"  \
        GET_TEE_VERSION="14.0.2-private" \
        bash xplatagent_install.sh \
    && echo "- Deleting things downloaded by vsoagent installer" \
    && rm -rf *.zip *.gz *.tar node-v*-linux* TEE-CLC-*

# TODO(ppanyukov): provide a better way to run this
# and also in daemonised mode.
#
# Really very basic way to run the agent for now.
# Requires an interactive shell for now because
# of password prompting etc.
CMD ["runtime/node/bin/node", "agent/vsoagent.js"]

