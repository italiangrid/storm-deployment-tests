#!/bin/bash

STORM_TARGET_RELEASE=${STORM_TARGET_RELEASE:-"stable"}
VOMS_TARGET_RELEASE=${VOMS_TARGET_RELEASE:-"stable"}
PKG_STORM_BRANCH=${PKG_STORM_BRANCH:-"none"}
PKG_STORM_PLATFORM=${PKG_STORM_PLATFORM:-"centos7java11"}
PKG_VOMS_BRANCH=${PKG_VOMS_BRANCH:-"none"}

echo "STORM_TARGET_RELEASE=${STORM_TARGET_RELEASE}"
echo "VOMS_TARGET_RELEASE=${VOMS_TARGET_RELEASE}"
echo "PKG_STORM_BRANCH=${PKG_STORM_BRANCH}"
echo "PKG_VOMS_BRANCH=${PKG_VOMS_BRANCH}"

# Copy host certificate and key
mkdir -p /etc/grid-security
cp /assets/node/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /assets/node/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Add only stable repo enabled
puppet apply /assets/node/repos/storm/stable.pp
puppet apply /assets/node/repos/voms/stable.pp

# Setup node via Puppet
puppet apply /assets/node/setup.pp