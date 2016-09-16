# Original xplat VSO agent

**THIS IS DEPRECATED AND IS NOT SUPPORTED**

Source: https://github.com/Microsoft/vso-agent


Docker hub images: https://hub.docker.com/r/ppanyukov/vso-agent-auto/tags/


## Docker Tags


- **latest --> centos7-0.6.5**


- **centos7-0.6.5**

    The latest release on centos 7 as of 24 May 2016.


- **centos7-0.6.5-git-lite-2.8.1**

    Same as `centos7-0.6.5`, except:

    - uses git 2.8.1 custom-built from source from here: https://github.com/ppanyukov/git-build

        This is a slimmer and later version than 1.8.3.1 that comes with
        official centos. This is same version as used in new VSTS agent image.


    - libcurl from www.city-fan.org

        The libcurl coming with centos 7 is too old and it does not
        work with OAuth authentication.

        This version of libcurl is installed as per instructions on
        given by VSTS project here: https://github.com/Microsoft/vsts-agent/blob/master/docs/preview/latebreaking.md

        This resolves the issue with OAuth authentication.


    This image may replace `centos7-0.6.5` is all goes well.


- **centos7-0.4.5**

    Old version, don't use unless you really need to.




## Known issues


- OAuth authentication scheme not working with visualstudio.com
  when using `centos7-0.4.5` or `centos7-0.6.5` images.

  The reason being the ancient version of `libcurl` which comes with
  official centos 7.

  The libcurl issue may get fixed at some point (would be nice) but it
  isn't as simple as it sounds.

  The workarounds are:

    - force basic authentication; or
    
    - use `centos7-0.6.5-git-lite-2.8.1` image with updated libcurl


