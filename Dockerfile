FROM nimbix/centos-base:7
MAINTAINER Nimbix, Inc.

COPY owncloud /tmp/owncloud
RUN /tmp/owncloud/owncloud-install.sh --with-httpd && \
    rm -rf /tmp/owncloud
COPY owncloud-start.sh /usr/local/bin/owncloud-start.sh

ENTRYPOINT ["/usr/local/bin/owncloud-start.sh"]

EXPOSE 443/tcp 22/tcp

COPY ./NAE/AppDef.json /etc/NAE/AppDef.json
