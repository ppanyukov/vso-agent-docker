#
# Docker file for building VSO xplat agent running on CentOS 7
# as provided by Microsoft here: https://github.com/Microsoft/vso-agent
#
# This version downloads stuff from https://github.com/Microsoft/vso-agent/releases
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
    --uid ${z_user_uid} ${z_user_name} 
    

# Use recent lite version of git built from source.
#
# NOTE: the use of dodgy-sounding www.city-fan.org is the repo
# given by official Microsoft VSTS project as the one to use
# to get the version of libcurl makes git work with VSO and OAuth.
#
RUN echo "Installing git-lite-2.8.1" \
    && pushd / \
    && yum -y install \
        wget \
        zlib \
    && rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel6/x86_64/city-fan.org-release-1-13.rhel6.noarch.rpm \
    && yum -y install \
        libcurl \
    && wget https://github.com/ppanyukov/git-build/releases/download/v0.0.1/git-lite-2.8.1.centos-7.tar.gz \
    && tar -zxvf git-lite-2.8.1.centos-7.tar.gz \
    && ln -s /usr/git/git-lite-2.8.1/bin/git /usr/local/bin/git \
    && rm -rf git-lite-2.8.1.centos-7.tar.gz


USER ${z_user_name}
WORKDIR ${z_user_home}

ARG z_vso_agent_version="0.6.5"

ENV \
    z_vso_agent_version=${z_vso_agent_version} 


# Install the thing
RUN echo "" \
    && echo "- Downloading release" \
    && cd /tmp \
    && wget "https://github.com/Microsoft/vso-agent/releases/download/${z_vso_agent_version}/xplat${z_vso_agent_version}Linux64.tar.gz"

# Note the tar.gz files here are not gz! They are plain tar.
# Should try both in case someone fixes it.
RUN echo "" \
    && cd /tmp \
    && tar -zxvf xplat${z_vso_agent_version}Linux64.tar.gz \
        || tar -xvf xplat${z_vso_agent_version}Linux64.tar.gz \
    && mv xplat${z_vso_agent_version}Linux64/* ~ \
    && rm -rf /tmp/* || true \
    && cd ~

USER root
RUN yum clean all
USER ${z_user_name}

# TODO(ppanyukov): provide a better way to run this
# and also in daemonised mode.
#
# Really very basic way to run the agent for now.
# Requires an interactive shell for now because
# of password prompting etc.
CMD ["runtime/node/bin/node", "agent/vsoagent.js"]


