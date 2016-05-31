FROM %BASE_IMAGE_TAG%

ADD run-vsts-docker-image.sh run-vsts-docker-image.sh

CMD ["bash", "run-vsts-docker-image.sh"]
