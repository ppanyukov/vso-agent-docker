#
# Docker file for building new VSTS agent which is the replacement of
# node-based VSO xplat agent. See details here:
#
# https://github.com/Microsoft/vsts-agent
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
RUN set +x \
    && echo "Creating user and group" \
    && groupadd -g ${z_user_gid} ${z_user_group_name} \
    && useradd \
    --create-home \
    --home-dir ${z_user_home} \
    --gid ${z_user_group_name}  \
    --no-user-group  \
    --uid ${z_user_uid} ${z_user_name} \
    && echo "- Adding prerequisite RPMs" 

# system prereqs as per https://github.com/Microsoft/vsts-agent/blob/master/docs/preview/latebreaking.md
#
# NOTES:
#   - The need for libcurl from www.city-fan.org is gone in this release.
#   - No longer need to install custom version of git as it comes bundled with VSTS tar.gz
#
RUN set +x \
    && echo "Installing prereqs" \
    && yum -y install \
        wget \
        libunwind \
        icu \
    && echo "Done installing RPMs"

USER ${z_user_name}
WORKDIR ${z_user_home}


ENV \
    z_vsts_agent_version="2.101.0"

# Install the thing
# NOTE: the agent seem to contain a copy of 
# node and tee (do we really need it?) amounting to
# the massive 69M. Zapping. It still wants text of license,
# so faking it. Still need node :(
RUN echo "" \
    && echo "- Downloading release" \
    && wget \
        "https://github.com/Microsoft/vsts-agent/releases/download/v${z_vsts_agent_version}/vsts-agent-rhel.7.2-x64-${z_vsts_agent_version}.tar.gz" \
        -O vsts-agent.tar.gz \
    && tar -zxvf vsts-agent.tar.gz \
    && rm -f vsts-agent.tar.gz \
    && rm -rf externals/tee \
    && mkdir -p externals/tee \
    && touch externals/tee/license.html


# TODO(ppanyukov): provide a better way to run this
# and also in daemonised mode.
#
# Really very basic way to run the agent for now.
# Requires an interactive shell for now because
# of password prompting etc.
CMD ["./bin/Agent.Listener"]


