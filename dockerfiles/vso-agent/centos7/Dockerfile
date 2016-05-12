#
# Docker file for building VSO xplat agent running on CentOS 7
# as provided by Microsoft here: https://github.com/Microsoft/vsts-agent
#

FROM centos:centos7
MAINTAINER ppanyukov@googlemail.com

# Parameters with reasonable defaults.
# Specify these using `docker build --build-arg <varname>=<value>`
# during build time. These will be exposed via env vars within
# the agent.

# The versins of VSO agent things to install, for repeatable
# builds.
#
# For available versions use:
#   npm view vsoagent-installer versions
# You obviously need node for this.
#
# The default is @0.4.5 which is the one I've been using
# privately and which generally works.
ARG z_vso_agent_version="@0.4.5"
ARG z_vso_agent_DEFAULT_NODE_VERSION="5.6.0"
ARG z_vso_agent_DEFAULT_TEE_VERSION="14.0.2-private"


#
# The name of the user to use within this container
# and home directory. Generally can be left as is unless
# there are special requirements to integrate with docker host.
ARG z_user_name=vsoagent 
ARG z_user_group_name=vsoagent 
ARG z_user_uid=1000 
ARG z_user_gid=1000 
ARG z_user_home=/home/${z_user_name}



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
        unzip \
        which

# Switch to the proper user and make sure everything runs in home dir
# No need for root at this point.
USER ${z_user_name}
WORKDIR ${z_user_home}


# Env available within container:
#   - X_* - the credentials vars.
#       TODO(ppanyukov): is this really how it always works??
#
#       Set here to empty strings to make sure whatever we do
#       docker run with these set to real values, the do not
#       show them at system-wide level. Just *that* little more
#       secure (possibly).
#
#       These will need to be passed with docker run to start
#       the agent.
#
#
#   - z_* - the build-time args
#
#   - GET_AGENT_VERSION - used by vso installer to fetch version
#
#   - VSO_AGENT_IGNORE - list of vars to never expose as capabilities
#
ENV \
    z_vso_agent_version="${z_vso_agent_version}" \
    z_vso_agent_DEFAULT_NODE_VERSION="${z_vso_agent_DEFAULT_NODE_VERSION}" \
    z_vso_agent_DEFAULT_TEE_VERSION="${z_vso_agent_DEFAULT_TEE_VERSION}" \
    z_user_name="${z_user_name}" \
    z_user_group_name="${z_user_group_name}" \
    z_user_uid="${z_user_uid}" \
    z_user_gid="${z_user_gid}" \
    z_user_home="${z_user_home}" \
    GET_AGENT_VERSION="${z_vso_agent_version}" \
    GET_DEFAULT_NODE_VERSION="${z_vso_agent_DEFAULT_NODE_VERSION}" \
    GET_DEFAULT_TEE_VERSION="${z_vso_agent_DEFAULT_TEE_VERSION}" \
    X_VSO_USERNAME="" \
    X_VSO_PASSWORD="" \
    X_VSO_URL="" \
    VSO_AGENT_IGNORE="X_VSO_USERNAME,X_VSO_PASSWORD,X_VSO_URL,VSO_CRED_TRACE,VSO_AGENT_VERBOSE"


# Install the thing
RUN echo "" \
    && echo "- The current dir is $(pwd)" \
    && echo "- whoami: $(whoami)" \
    && echo "- home dir: $(echo $HOME)" \
    && curl -skSL http://aka.ms/xplatagent | bash \
    && echo "- Deleting things downloaded by vsoagent installer" \
    && rm -rf *.zip *.gz *.tar node-v*-linux* TEE-CLC-* \
    && echo "- Making _work directory for vso agent" \
    && mkdir _work

# Unfortunately need to be root for this
USER root
RUN echo \
    && echo "Zapping yum cache" \
    && yum clean all

USER ${z_user_name}

# TODO(ppanyukov): provide a better way to run this
# and also in daemonised mode.
#
# Really very basic way to run the agent.
# Requires an interactive shell for now because
# of password prompting etc.
CMD ["runtime/node/bin/node", "agent/vsoagent.js"]


