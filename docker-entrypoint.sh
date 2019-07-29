#!/bin/sh
set -e

# Copy existing custom configuration files
echo "Copy custom configuration files ..."
if [ -d ./config ]; then
    cp -R -f "./config/"* /opt/shinobi || echo "No custom config files found." 
fi

# Create default configurations files from samples if not existing
if [ ! -f /opt/shinobi/conf.json ]; then
    echo "Create default config file /opt/shinobi/conf.json ..."
    cp /opt/shinobi/conf.sample.json /opt/shinobi/conf.json
fi

if [ ! -f /opt/shinobi/super.json ]; then
    echo "Create default config file /opt/shinobi/super.json ..."
    cp /opt/shinobi/super.sample.json /opt/shinobi/super.json
fi

if [ ! -f /opt/shinobi/plugins/motion/conf.json ]; then
    echo "Create default config file /opt/shinobi/plugins/motion/conf.json ..."
    cp /opt/shinobi/plugins/motion/conf.sample.json /opt/shinobi/plugins/motion/conf.json
fi

# Hash the admins password
if [ -n "${ADMIN_PASSWORD}" ]; then
    echo "Hash admin password ..."
    ADMIN_PASSWORD_MD5=$(echo -n "${ADMIN_PASSWORD}" | md5sum | sed -e 's/  -$//')
fi

# Create MySQL database if it does not exists
echo "Wait for MySQL server" ...
mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait=10

echo "Create database schema if it does not exists ..."
mysql -u $MYSQL_USER -h $MYSQL_HOST --password="$MYSQL_PASSWORD" -e "source /opt/shinobi/sql/framework.sql" $MYSQL_DATABASE || true

echo "Set keys for CRON and PLUGINS from environment variables ..."
sed -i -e 's/"key":"73ffd716-16ab-40f4-8c2e-aecbd3bc1d30"/"key":"'"${CRON_KEY}"'"/g' \
       -e 's/"Motion":"d4b5feb4-8f9c-4b91-bfec-277c641fc5e3"/"Motion":"'"${PLUGINKEY_MOTION}"'"/g' \
       -e 's/"OpenCV":"644bb8aa-8066-44b6-955a-073e6a745c74"/"OpenCV":"'"${PLUGINKEY_OPENCV}"'"/g' \
       -e 's/"OpenALPR":"9973e390-f6cd-44a4-86d7-954df863cea0"/"OpenALPR":"'"${PLUGINKEY_OPENALPR}"'"/g' \
       "/opt/shinobi/conf.json"

# Set the admin password
if [ -n "${ADMIN_USER}" ]; then
    if [ -n "${ADMIN_PASSWORD_MD5}" ]; then
        sed -i -e 's/"mail":"admin@shinobi.video"/"mail":"'"${ADMIN_USER}"'"/g' \
            -e "s/21232f297a57a5a743894a0e4a801fc3/${ADMIN_PASSWORD_MD5}/g" \
            "/opt/shinobi/super.json"
    fi
fi

# Change the uid/gid of the node user
if [ -n "${GID}" ]; then
    if [ -n "${UID}" ]; then
        groupmod -g ${GID} node && usermod -u ${UID} -g ${GID} node
    fi
fi

cd /opt/shinobi
node tools/modifyConfiguration.js cpuUsageMarker=CPU >/dev/null
node tools/modifyConfiguration.js utcOffset=$utcOffset >/dev/null
node tools/modifyConfiguration.js db="{\"host\": \"$MYSQL_HOST\", \"user\": \"$MYSQL_USER\", \"password\": \"$MYSQL_PASSWORD\", \"database\": \"$MYSQL_DATABASE\", \"port\": \"3306\" }" >/dev/null
node tools/modifyConfiguration.js addToConfig='{"discordBot":true}' >/dev/null

# Execute Command
echo "Starting Shinobi ..."
exec "$@"
