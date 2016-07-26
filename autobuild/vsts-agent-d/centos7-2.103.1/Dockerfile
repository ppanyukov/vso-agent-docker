FROM ppanyukov/vsts-agent-auto:centos7-2.103.1

# We will run as root and then su to vsoagent to secure
# env vars etc.
USER root

COPY files/* /home/vsoagent/

CMD ["/bin/bash", "./run-vsts-agent-d.sh"]
