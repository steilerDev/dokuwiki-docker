#!/bin/bash
echo "Welcome to dokuwiki docker by steilerDev"

echo "Moving distro files..."
cp -nr /distro/data/* /data/
cp -nr /distro/conf/* /conf/
echo "...done"

if [ ! -f /conf/local.php ]; then
    echo "Creating /conf/local.php based on env-variables..."

# Making sure php does not break
conf='$conf' \
TITLE="${TITLE:-DokuWiki}" \
WIKI_LANG="${WIKI_LANG:-en}" \
LICENSE="${LICENSE:-cc-by-sa}" \
USEACL="${USEACL:-1}" \
SUPERUSER="${SUPERUSER:-@admin}" \
DISABLE_ACTIONS="${DISABLE_ACTIONS:-register}" \
envsubst < /distro/docker/local.php.docker > /conf/local.php

    echo "...done:"
    cat /conf/local.php
else
    echo "/conf/local.php exists, not changing"
fi

if [ ! -f /conf/users.auth.php ]; then
    echo "Creating /conf/users.auth.php based on env-variables..."

    # Default password of 'password', pre-hashed
    PASSHASH_DEFAULT='$2y$10$0a3SbrGSQReVkeaFvfCS0.YrslJgFYq05lOh7Za9FTxQjKTiMORcG'

    #making sure only lower case usernames are stored
    USER=${USER,,}

USER="${USER:-admin}" \
PASSHASH="${PASSHASH:-$PASSHASH_DEFAULT}" \
NAME="${NAME:-John}" \
EMAIL="${EMAIL:-john@doe.com}" \
envsubst < /distro/docker/users.auth.php.docker > /conf/users.auth.php

    echo "...done:"
    cat /conf/users.auth.php
else
    echo "/conf/users.auth.php exists, not changing"
fi

if [ ! -f /conf/acl.auth.php ]; then
    echo "Creating /conf/acl.auth.php based on env-variables..."

ACL_ALL="${ACL_ALL:-1}" \
ACL_USER="${ACL_USER:-8}" \
envsubst < /distro/docker/acl.auth.php.docker > /conf/acl.auth.php

    echo "...done:"
    cat /conf/acl.auth.php
else
    echo "/conf/acl.auth.php exists, not changing"
fi

if [ ! -f /conf/plugins.local.php ]; then
    echo "Creating /conf/plugins.local.php based on env-variables..."
    cp /distro/docker/plugins.local.php.docker /conf/plugins.local.php
    echo "...done:"
    cat /conf/plugins.local.php
else
    echo "/conf/plugins.local.php exists, not changing"
fi
    

echo "Fixing permissions & ownerships..."
chown -R www-data:www-data /{conf,site,data}
chmod -R g=rwX,u=rwX,o=rX /data/
chmod 2775 /data/{attic,cache,index,locks,media,meta,pages,tmp}/
chown root:root -R /site/bin/ /site/install.php
chmod -R 0 /site/bin/ /site/install.php

echo "...setup finished!"
