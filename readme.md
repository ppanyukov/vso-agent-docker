Base unconfigured Centos 7 based Docker images for the VSO agents.


**WORK IN PROGRESS.** Things may change or disappear quickly.


## Agents:

1. **xplat agent**

    The original cross-platform VSO agent (aka xplat agent, https://github.com/Microsoft/vso-agent)

    Pre-built docker images: https://hub.docker.com/r/ppanyukov/vso-agent-auto/tags/

    The agent broadly works, although not without issues.

    This agent is planned to be replaced with unifined VSTS agent (soon they say).

    See [xplat-agent.md](xplat-agent.md) for details.



2. **VSTS agent**

    The new unified agent (https://github.com/Microsoft/vsts-agent/).

    This agent is in preview as of 24 May 2016 .

    Pre-built docker images: https://hub.docker.com/r/ppanyukov/vsts-agent-auto/tags/

    See [vsts-agent.md](vsts-agent.md) for detail.


