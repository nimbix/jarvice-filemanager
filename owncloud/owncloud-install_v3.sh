#!/bin/bash

apt-get update
apt-get install pwgen pwauth wget -y
wget https://framagit.org/veretcle/user_pwauth/-/archive/master/user_pwauth-master.tar.gz
tar xvzf user_pwauth-master.tar.gz
mv user_pwauth-master/user_pwauth /var/www/owncloud/apps
/usr/sbin/groupadd -g 505 nimbix
/usr/sbin/useradd -u 505 -g 505 -m -s /bin/bash -p '$6$3LXq6DwMpqnK5o8V$30G8uiWZ5OY5ycRFFlz0JpxhsSogLQy.Muv04tOkFplUYkVNpIkvGoFpGJ08epJ7EWDwaQ6g6bY3/08HEyOHY1' nimbix

usermod -a -G www-data nimbix
usermod -a -G tty nimbix
sed -i '1 a\return 0' /etc/owncloud.d/25-chown.sh
sed -i '1 a\return 0' /etc/owncloud.d/55-cron.sh
sed -i 's/\/mnt/\/home\/nimbix/' /etc/entrypoint.d/50-folders.sh
sed -i 's/8080/5902/' /etc/entrypoint.d/98-overwrite.sh
sed -i 's/8080/5902/' /etc/entrypoint.d/99-apache.sh
echo 'Listen 5902' > /etc/apache2/ports.conf
chown -R nimbix:nimbix /var/www/owncloud
mkdir /home/nimbix/data
chown -R nimbix:nimbix /home/nimbix/data
mkdir -p /var/run/apache2
mkdir -p /var/log/apache2
chown -R nimbix:nimbix /var/run/apache2
chown -R nimbix:nimbix /var/log/apache2
chown -R nimbix:nimbix /var/lib/apache2
chown -R nimbix:nimbix /etc/apache2
chown -R nimbix:nimbix /etc/templates
chown -R nimbix:nimbix /etc/php

apt-get install sudo -y

sudo -u nimbix /usr/bin/timeout 10 /usr/bin/entrypoint /usr/bin/owncloud server

sudo -u nimbix /bin/bash -c '
cd /var/www/owncloud
occ=occ

$occ app:enable user_pwauth
$occ config:app:set --value=/usr/sbin/pwauth user_pwauth pwauth_path
# Modify the "routes" registration..
sed -i -e "s/showLoginForm/tryLogin/g" core/routes.php
# Don"t check requesttoken
sed -i -e "s/passesCSRFCheck() {/passesCSRFCheck() { return true;/" \
    lib/private/AppFramework/Http/Request.php

# Deleting trusted_domains config doesn"t work due to bug in isTrustedDomain
sed -i -e "s/return in_array.*/return true;/" \
    lib/private/Security/TrustedDomainHelper.php

# Don"t allow the user to change name and password
sed -i -e "s/.*displayNameChangeSupported.*//" \
    settings/personal.php
sed -i -e "s/.*passwordChangeSupported.*//" \
    settings/personal.php

sed -i "s/Port)\ {/Port) {return true;/" lib/private/Security/TrustedDomainHelper.php

OC_USER=nimbix
OC_USER_UID=$(/usr/bin/id -u $OC_USER 2>/dev/null)
$occ config:app:set --value=$OC_USER_UID user_pwauth uid_list


$occ config:system:set --type=string --value=owncloud log_type
$occ config:system:set --type=int --value=2 loglevel
$occ config:system:set --type=bool --value=true check_for_working_htaccess
names="updatechecker appstoreenabled knowledgebaseenabled enable_avatars"
names+=" allow_user_to_change_display_name"
for name in $names; do     $occ config:system:set --type=bool --value=false $name; done
# Remove unnecessary apps that could confuse users
apps="files_sharing files_versions files_trashbin activity gallery systemtags"
apps+=" notifications templateeditor firstrunwizard"
#apps+=" federatedfilesharing"  # federatedfilesharing can"t be disabled?
for app in $apps; do     $occ app:disable $app; done
$occ config:system:set --type=bool --value=false apps_paths 1 writable
# Configure external storage
$occ app:enable files_external
$occ files_external:create / local null::null
$occ files_external:config 1 datadir /data
$occ files_external:option 1 enable_sharing true
$occ config:app:set     --value "ftp,dav,owncloud,sftp,amazons3,dropbox,googledrive,swift,smb"     files_external user_mounting_backends
$occ config:system:set --type=int --value=1 filesystem_check_changes
$occ config:system:set skeletondirectory
$occ config:system:set --type=bool --value=true config_is_read_only
'

#OC_URL="https://%PUBLICADDR%/owncloud/index.php/login?user=%NIMBIXUSER%&password=%NIMBIXPASSWD%"
OC_URL="https://%PUBLICADDR%:5902/login?user=nimbix&password=nimbix"
OC_CLIENTS="https://owncloud.org/sync-clients/"
mkdir -p /etc/NAE
cat <<EOF | sudo tee /etc/NAE/url.txt >/dev/null
$OC_URL
EOF

cat <<EOF | sudo tee /etc/NAE/help.html >/dev/null
<h1><a href="$OC_URL" target="%JOBNAME%">Click Here to Connect</a></h1>
<p>
Alternatively, you may connect securely with an
<a href="$OC_CLIENTS" target="_owncloud_download"><b>ownCloud desktop or mobile client</b></a>:
</p>
<p>
<table>
<tr>
<td align="right">ownCloud Server:</td>
<td><b>https://%PUBLICADDR%:5902</b><br></td>
</tr>
<tr>
<td align="right">User:</td>
<td><b>nimbix</b><br></td>
</tr>
<tr>
<td align="right">Password:</td>
<td><b>nimbix</b><br></td>
</tr>
</table>
</p>
<p>
Please note that the password is case sensitive and should not contain any
leading or trailing spaces when entered.  It is recommended that you copy and
paste it from above directly into the ownCloud client password prompt to
ensure accuracy.
</p>
<p>
<a href="$OC_CLIENTS" target="_owncloud_download"><b>Click here to download an ownCloud desktop or mobile client</b></a><br>
</p>

<h2>Alternative Connection Methods</h2>
<p>
You may also upload and download files from the command line with a tool
like curl:
<pre style="overflow-x:scroll;">
curl -u %NIMBIXUSER%:%NIMBIXPASSWD% -k --upload-file "source_file" "https://%PUBLICADDR%/owncloud/remote.php/webdav/target_file"<br>
</pre>
<pre style="overflow-x:scroll;">
curl -u %NIMBIXUSER%:%NIMBIXPASSWD% -k --output "target_file" "https://%PUBLICADDR%/owncloud/remote.php/webdav/source_file"
</pre>
</p>

<p>
A <a href="https://github.com/owncloud/pyocclient" target="_owncloud_download"><b>python client library for ownCloud</b></a> is also available for
programmatically accessing files via ownCloud APIs.
</p>
EOF

exit 0
