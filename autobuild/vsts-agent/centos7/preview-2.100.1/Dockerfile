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
        wget

# system prereqs as per https://github.com/Microsoft/vsts-agent/blob/master/docs/preview/latebreaking.md
#
# TODO(ppanyukov): nope, I'm not installing curl from www.city-fan.org!
# TODO(ppanyukov): yes :( we need it. Otherwise we are going to get
#   fatal: Authentication failed for 'https://OAuth:********@blah.visualstudio.com/project/_git/repo/'
#   2016-05-16T19:34:19.6230250Z ##[error]Git fetch failed with exit code: 128
#
RUN echo "" \
    && echo "Installing prereqs" \
    && yum -y install \
        libunwind \
        icu \
    && rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel6/x86_64/city-fan.org-release-1-13.rhel6.noarch.rpm \
    && yum -y install libcurl

# Recent version of git (>=1.9.1) is required for pulling sources from VSO.
# Use custom-built git as we only have 1.8.x official RPM.
# Also the official RPM is too fat.
#
RUN echo "Installing git" \
    && pushd / \
    && wget https://github.com/ppanyukov/git-build/releases/download/v0.0.1/git-lite-2.8.1.centos-7.tar.gz \
    && tar -zxvf git-lite-2.8.1.centos-7.tar.gz \
    && ln -s /usr/git/git-lite-2.8.1/bin/git /usr/local/bin/git \
    && rm -rf git-lite-2.8.1.centos-7.tar.gz


USER ${z_user_name}
WORKDIR ${z_user_home}


ENV \
    z_vsts_agent_version="2.100.1"

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


