#!/bin/bash
#
# Init script
#
###########################################################

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Replace environment variables with real values
sedeasy "GMAIL_ADDRESS" "$GMAIL_ADDRESS" /etc/gplayweb.conf
sedeasy "GMAIL_PASSWORD" "$GMAIL_PASSWORD" /etc/gplayweb.conf
sedeasy "ANDROID_ID" "$ANDROID_ID" /etc/gplayweb.conf
sedeasy "GPLAYWEB_LANGUAGE" "$GPLAYWEB_LANGUAGE" /etc/gplayweb.conf
sedeasy "HTTP_ROOT" "$DATA_DIR/fdroid/repo" /etc/Caddyfile

# Fix permissions
find $DATA_DIR -type d -exec chmod 775 {} \;
find $DATA_DIR -type f -exec chmod 664 {} \;
chown -R root:root $DATA_DIR

# Start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
