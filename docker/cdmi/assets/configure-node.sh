#!/bin/bash

echo "TARGET_RELEASE=${TARGET_RELEASE}"

# Install host certificate and key
mkdir -p /etc/grid-security
cp /assets/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /assets/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# clean all
yum clean all
yum install -y nc

# Install puppet and base modules
rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm
yum install -y puppet
puppet module install maestrodev-wget
puppet module install puppetlabs-ntp

# Setup node
puppet apply --detailed-exitcodes /assets/setup/manifest.pp

# Install storm puppet module
git clone https://github.com/enricovianello/storm-puppet-module.git /storm-puppet-module
cd /storm-puppet-module
puppet module build
puppet module install ./pkg/mwdevel-storm-0.1.0.tar.gz

# Add the right enabled repository
puppet apply /assets/repos/${TARGET_RELEASE}.pp