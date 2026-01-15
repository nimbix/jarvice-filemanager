FROM owncloud/server:latest
MAINTAINER Nimbix, Inc.

COPY owncloud /tmp/owncloud

RUN /tmp/owncloud/owncloud-install_v3.sh

RUN apt-get install vim -y && apt-get clean

#ENTRYPOINT ["/usr/bin/entrypoint"]
#CMD ["/usr/bin/owncloud", "server"]

#EXPOSE 8080/tcp

EXPOSE 5902/tcp

COPY ./NAE/AppDef.json /etc/NAE/AppDef.json

