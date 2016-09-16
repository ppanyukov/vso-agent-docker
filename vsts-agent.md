# Base unconfigured VSTS agent

Original source: https://github.com/Microsoft/vsts-agent

Docker hub images: https://hub.docker.com/r/ppanyukov/vsts-agent-auto/tags/

This is a completely base install of the agent.


## Tags

*These may be out of date, but gives an idea*

- `latest` --> `centos7-latest`

- `centos7-latest` --> `centos7-2.106`

- `centos7-2.106`

    - this image uses custom-built `git 2.9.0` from this repository:
      https://github.com/ppanyukov/git-build


## Older images

There are quite a few, you probably don't want to use them though because
VSTS forces auto-update and older images will not run.

For the image correctly hadling auto-update see `vsts-agent-d`.