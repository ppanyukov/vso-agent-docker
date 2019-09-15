# DO NOT USE

There is no longer a need for this project. All features are now incorporated equally or better into official Microsoft images.

Use them instead.

- Docker image: https://hub.docker.com/_/microsoft-azure-pipelines-vsts-agent 

- Github repo: https://hub.docker.com/_/microsoft-azure-pipelines-vsts-agent 

-------



# Agents:


## 1. vsts-agent

Base unconfigured agent Docker image on Centos 7.

NOTE that due to the VSTS auto-update feature these images are generally
unsuitable for running in a daemonised mode. You probably want `vsts-agent-d`
for this.

The git repo for agent: https://github.com/Microsoft/vsts-agent/

Pre-built docker images: https://hub.docker.com/r/ppanyukov/vsts-agent-auto/tags/

See [vsts-agent.md](https://github.com/ppanyukov/vso-agent-docker/blob/master/vsts-agent.md) for more detail.


## 2. vsts-agent-d

This is the one you probably want to use if you want a good working agent.

Image is built on top of base `vsts-agent` to run in unattended
mode on VMs and on clusters, with several features and enhancements
required to support this.

Pre-built docker images: https://hub.docker.com/r/ppanyukov/vsts-agent-d/tags/

Briefly:

- fully parameterised VSTS configuration (credentials, etc)

- supports daemonised and interactive modes of running

- graceful restarts in case of crashes 
  (e.g. with `docker run -d --restart=always`)

- agent naming to aid identification in VSO pools

- agent naming to have predictable ordering in the pool

- correct handling of SIGTERM

- removal of agent registration from VSO on stop

- security features

- auto-update on start and restart

- can build and run docker images using host's docker daemon


For full docs see [vsts-agent-d.md](https://github.com/ppanyukov/vso-agent-docker/blob/master/vsts-agent-d.md)



## 3. vso-agent (aka xplat agent) - DEPRECATED

Base unconfigured agent Docker image on Centos 7.

The original cross-platform VSO agent (aka xplat agent, see https://github.com/Microsoft/vso-agent)

Pre-built docker images: https://hub.docker.com/r/ppanyukov/vso-agent-auto/tags/

Latest release: 0.6.5

The agent broadly works, although not without issues.

This agent is planned to be replaced with unifined VSTS agent (soon they say).

See [xplat-agent.md](https://github.com/ppanyukov/vso-agent-docker/blob/master/vso-agent.md) for details.


