# Original xplat VSO agent

Source: https://github.com/Microsoft/vso-agent


Docker hub images: https://hub.docker.com/r/ppanyukov/vso-agent-auto/tags/


## Docker Tags


- latest --> centos7-0.6.5


- centos7-0.6.5

    The latest release on centos 7 as of 24 May 2016.


- centos7-0.4.5

    Old version, don't use unless you really need to.


## Known issues


- OAuth authentication scheme not working with visualstudio.com

  The reason being the ancient version of `libcurl` which comes with
  official centos 7.

  The libcurl issue may get fixed at some point (would be nice) but it
  isn't as simple as it sounds.

  The workaround is to force basic authentication.


