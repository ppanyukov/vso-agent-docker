FROM ppanyukov/vsts-agent-auto:centos7-preview-2.101.1

# We will run as root and then su to vsoagent to secure
# env vars etc.
USER root

ADD files/run-vsts-agent-d.sh run-vsts-agent-d.sh

CMD ["/bin/bash", "./run-vsts-agent-d.sh"]
