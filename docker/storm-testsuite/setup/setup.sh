#!/bin/bash

echo 'export X509_USER_PROXY="/tmp/x509up_u$(id -u)"'>/etc/profile.d/x509_user_proxy.sh

puppet apply /setup/manifest.pp

# Add tester user
adduser -d /home/tester tester

# .globus
mkdir /home/tester/.globus
chown tester:tester /home/tester/.globus