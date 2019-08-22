#!/bin/bash
set -x

# setup host certificate and key
cp /assets/storm-certificates/storm-example-cert.pem /etc/grid-security/hostcert.pem
chmod 644 /etc/grid-security/hostcert.pem
cp /assets/storm-certificates/storm-example-key.pem /etc/grid-security/hostkey.pem
chmod 400 /etc/grid-security/hostkey.pem

# execute main script
cd /assets/scripts
chmod +x "main.sh"
./main.sh

# disable frontend monitor
sed -i -e '/monitoring.enabled=true/c\monitoring.enabled=false' /etc/storm/frontend-server/storm-frontend-server.conf

sh /assets/daemons/frontend
