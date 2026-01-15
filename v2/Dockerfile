FROM gcr.io/jarvice/app-filemanager:ocpassform-sameorigin

RUN chmod -R 777 /usr /etc /run /var; \
    chmod -R 777 /run/httpd; \
    sed -i "/smbpasswd/d" /usr/local/bin/owncloud-start.sh; \
    sed -i "s/sudo//g" /usr/local/bin/owncloud-start.sh; \
    sed -i "s/Listen\ 80/Listen 5902/" /etc/httpd/conf/httpd.conf; \
    sed -i "s/Listen\ 443/Listen 8443/" /etc/httpd/conf.d/ssl.conf; \
    sed -i "99s/false/\$uid/" /var/lib/owncloud/apps/user_pwauth/user_pwauth.php; \
    sed -i "101s/false/\$uid/" /var/lib/owncloud/apps/user_pwauth/user_pwauth.php; \
    rm -f /etc/httpd/conf.d/ssl.conf; \
    rm -f /etc/NAE/AppDef.json; \
    echo 'https://%PUBLICADDR%:5902/owncloud/index.php/login?user=%NIMBIXUSER%&password=%NIMBIXPASSWD%' > /etc/NAE/url.txt

COPY AppDef.json /etc/NAE/AppDef.json
 
