#!/bin/bash
set -x

MODE="${MODE:-clean}"
PLATFORM="${PLATFORM:-centos6}"
DEPLOYMENT_SCRIPT="${MODE}-deployment_${PLATFORM}.sh"

cd /data

chmod +x ${DEPLOYMENT_SCRIPT}
./${DEPLOYMENT_SCRIPT}

# disable frontend monitor
sed -i -e '/monitoring.enabled=true/c\monitoring.enabled=false' /etc/storm/frontend-server/storm-frontend-server.conf

sh /daemons/frontend
