#!/bin/bash
set -x
# export DEBUG="true"
[[ "${DEBUG}" == "true" ]] && set -x || true
OC_HOMEDIR=/var/www/owncloud
# OC_CONFIG_ROOT="$HOME/owncloud"
OC_CONFIG_ROOT=/etc/skel/owncloud
JARVICE_ID_USER="${JARVICE_ID_USER:-nimbix}"

# note that /var/www/owncloud is not writable, so instead we put a broken
# link there at build time, and next we'll link the proper directory to
# that broken link (2 symlinks)
ln -s $HOME/owncloud_root /tmp/owncloud_root

OC_USER="$JARVICE_ID_USER"
OC_GROUP=$(id -g ${JARVICE_ID_USER:-nimbix})
mkdir -p /tmp/sites-enabled
export OWNCLOUD_SUB_URL="/${JARVICE_INGRESSPATH:-}"
export OWNCLOUD_OVERWRITE_CLI_URL="http://localhost${OWNCLOUD_SUB_URL}"
export OWNCLOUD_DOMAIN="localhost,http://localhost,https://localhost"
export OWNCLOUD_TRUSTED_DOMAINS=${OWNCLOUD_DOMAIN}
export OWNCLOUD_HTACCESS_REWRITE_BASE="${OWNCLOUD_SUB_URL}"

source $OC_CONFIG_ROOT/owncloud-setup.sh
source $OC_CONFIG_ROOT/owncloud-db.sh

export OWNCLOUD_SESSION_SAVE_PATH=${OWNCLOUD_VOLUME_SESSIONS}
export APACHE_ERROR_LOG="/tmp/apache2.out.log"
export APACHE_LOG_LEVEL="info"
export APACHE_RUN_USER="$OC_USER"
# export APACHE_RUN_GROUP="$OC_GROUP"
export APACHE_RUN_GROUP=$(id -gn ${JARVICE_ID_USER:-nimbix})
export JARVICE_JOBTOKEN64=${JARVICE_JOBTOKEN:0:64}
export APACHE_LISTEN=${JARVICE_SERVICE_PORT:-5902}

ln -s ${OWNCLOUD_VOLUME_CONFIG} /var/www/owncloud/config
ln -s ${OWNCLOUD_VOLUME_APPS} /var/www/owncloud/custom

echo "Starting owncloud"
owncloud server
