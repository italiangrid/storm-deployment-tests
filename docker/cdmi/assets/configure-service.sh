#!/bin/bash
set -ex
trap "exit 1" TERM

REDIS_HOSTNAME="${REDIS_HOSTNAME:-redis.test.example}"
CDMI_CLIENT_ID="${CDMI_CLIENT_ID:-838129a5-84ca-4dc4-bfd8-421ee317aabd}"
CDMI_CLIENT_SECRET="${CDMI_CLIENT_SECRET:-secret}"

# Install indigodc-release
rpm --import https://repo.indigo-datacloud.eu/repository/RPM-GPG-KEY-indigodc
yum localinstall -y https://repo.indigo-datacloud.eu/repository/indigo/2/centos7/x86_64/base/indigodc-release-2.0.0-1.el7.centos.noarch.rpm
yum-config-manager --disable INDIGO-2-base

# yum install -y cdmi-server
yum localinstall -y https://ci.cloud.cnaf.infn.it/job/CDMI/job/master/lastSuccessfulBuild/artifact/cdmi-server-1.2.1-1.el7.x86_64.rpm

# install cdmi_storm
yum install -y cdmi-storm

# Configure
APPLICATION_CONFIG_PATH="/var/lib/cdmi-server/config"
PLUGINS_CONFIG_PATH="/etc/cdmi-server/plugins"

rm -rf ${APPLICATION_CONFIG_PATH}/application.yml
cp -rf /assets/data/config/application.yml ${APPLICATION_CONFIG_PATH}/application.yml

sed -i "s/REDIS_HOSTNAME/${REDIS_HOSTNAME}/g" ${APPLICATION_CONFIG_PATH}/application.yml
sed -i "s/CLIENT_ID/${CDMI_CLIENT_ID}/g" ${APPLICATION_CONFIG_PATH}/application.yml
sed -i "s/CLIENT_SECRET/${CDMI_CLIENT_SECRET}/g" ${APPLICATION_CONFIG_PATH}/application.yml

mkdir -p ${PLUGINS_CONFIG_PATH}
cp -rf /assets/data/config/capabilities ${PLUGINS_CONFIG_PATH}
cp -rf /assets/data/config/storm-properties.json ${PLUGINS_CONFIG_PATH}/storm-properties.json

# Wait for redis server
WAIT_TIMEOUT=${WAIT_TIMEOUT:-600}

chmod +x /assets/scripts/wait-for-it.sh
/assets/scripts/wait-for-it.sh ${REDIS_HOSTNAME}:6379 --timeout=${WAIT_TIMEOUT}

echo "export JAVA_OPTS=\"-Dloader.path=/usr/lib/cdmi-server/plugins/\"" >> /etc/profile.d/cdmi.sh
chmod +x /etc/profile.d/cdmi.sh

systemctl start cdmi-server