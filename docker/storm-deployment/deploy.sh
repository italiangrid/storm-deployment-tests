#!/bin/bash
set -x

cd /scripts
chmod +x "main.sh"
./main.sh

# disable frontend monitor
sed -i -e '/monitoring.enabled=true/c\monitoring.enabled=false' /etc/storm/frontend-server/storm-frontend-server.conf

sh /daemons/frontend
