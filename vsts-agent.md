# New VSTS agent

Original source: 

Docker hub images: https://hub.docker.com/r/ppanyukov/vsts-agent-auto/tags/


## Tags


- latest --> centos7-latest


- centos7-latest --> centos7-preview-2.100.1


- centos7-preview-2.100.1

    - The latest preview release on centos 7 as of 24 May 2016.


    - uses git 2.8.1 custom-built from source from here: https://github.com/ppanyukov/git-build

        The git version 1.8.3.1 which comes with official centos 7 is too
        old and does not work with VSTS agent.

        The minimum required is 1.9.1


    - libcurl from www.city-fan.org

        The libcurl coming with centos 7 is too old and it does not
        work with OAuth authentication.

        This version of libcurl is installed as per instructions on
        given by VSTS project here: https://github.com/Microsoft/vsts-agent/blob/master/docs/preview/latebreaking.md



## Known issues

probably lots




