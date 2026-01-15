FROM us-docker.pkg.dev/jarvice-apps/images/filemanager:oc10.9-v2-test

# pivot /var/www/owncloud to a link that will be resolved at runtime once
# the container user is known
RUN rm -Rf /var/www/owncloud && ln -s /tmp/owncloud_root /var/www/owncloud
COPY owncloud-start.sh /usr/local/bin/owncloud-start.sh
COPY server /usr/bin/server

# make writable Apache log and template directories
RUN rm -rf /etc/apache2/sites-enabled && ln -s /tmp/sites-enabled /etc/apache2/sites-enabled
RUN rm -rf /etc/apache2/logs && ln -s /tmp /etc/apache2/logs
RUN userdel -r nimbix

# fix Apache configuration
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i 's/^.*ErrorLog.*$//' /etc/apache2/apache2.conf && sed -i 's/^.*CustomLog.*$//' /etc/apache2/apache2.conf
