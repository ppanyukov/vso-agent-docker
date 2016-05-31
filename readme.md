Base unconfigured Centos 7 based Docker images for the VSO agents.


**WORK IN PROGRESS.** Things may change or disappear quickly.


## Agents:

1. **xplat agent**

    The original cross-platform VSO agent (aka xplat agent, https://github.com/Microsoft/vso-agent)

    Pre-built docker images: https://hub.docker.com/r/ppanyukov/vso-agent-auto/tags/

    Latest release: 0.6.5

    The agent broadly works, although not without issues.

    This agent is planned to be replaced with unifined VSTS agent (soon they say).

    See [xplat-agent.md](https://github.com/ppanyukov/vso-agent-docker/blob/master/xplat-agent.md) for details.



2. **VSTS agent**

    The new unified agent (https://github.com/Microsoft/vsts-agent/).

    This agent is in preview as of 26 May 2016 .

    Latest release: 2.101.0

        - no longer need libcurl from www.city-fan.org
        - no longer need custom-built git as it now comes bundled with VSTS tar.gz

    Pre-built docker images: https://hub.docker.com/r/ppanyukov/vsts-agent-auto/tags/

    See [vsts-agent.md](https://github.com/ppanyukov/vso-agent-docker/blob/master/vsts-agent.md) for detail.



3. **VSTS agent for Azure Container Services (ACS) and Marathon on Mesos**

    Experimental. See readme https://github.com/ppanyukov/vso-agent-acs/readme.md

