FROM ppanyukov/vsts-agent-auto:centos7-2.103.0

# We will run as root and then su to vsoagent to secure
# env vars etc.
USER root

ADD files/run-vsts-agent-d.sh run-vsts-agent-d.sh

CMD ["/bin/bash", "./run-vsts-agent-d.sh"]
