#!/bin/bash
set -ex
trap "exit 1" TERM

# StoRM WebDAV needs to know what host has not to be considered as a 3rd-party copy
echo ""  >> /etc/sysconfig/storm-webdav
echo "STORM_WEBDAV_HOSTNAME_0=\"storm.example\"" >> /etc/sysconfig/storm-webdav

# Explicit set conscrypt use to true
echo ""  >> /etc/sysconfig/storm-webdav
echo "STORM_WEBDAV_USE_CONSCRYPT=\"true\"" >> /etc/sysconfig/storm-webdav

# Add TLS debug
sed '/^STORM_WEBDAV_JVM_OPTS/ d'
echo ""  >> /etc/sysconfig/storm-webdav
echo "STORM_WEBDAV_JVM_OPTS=\"-Xms256m -Xmx512m -Djava.io.tmpdir=/var/lib/storm-webdav/work -Djavax.net.debug=all\"" >> /etc/sysconfig/storm-webdav
