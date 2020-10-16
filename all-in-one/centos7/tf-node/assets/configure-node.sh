#!/bin/bash

echo "TARGET_RELEASE=${TARGET_RELEASE}"

# Copy host certificate and key
mkdir -p /etc/grid-security
cp /assets/node/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /assets/node/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Install needed modules
puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl
puppet module install puppet-epel
puppet module install cnafsd-bdii
puppet module install cnafsd-umd4
puppet module install cnafsd-testvos
puppet module install cnafsd-testca
puppet module install cnafsd-lcmaps
puppet module install cnafsd-sd_users

# Install storm puppet module
if [ -d "/storm-puppet-module" ] 
then
    echo "Directory /storm-puppet-module exists." 
    cd /storm-puppet-module
    rm -rf ./pkg
    puppet module uninstall cnafsd-storm
else
    echo "Directory /storm-puppet-module does not exists."
    git clone https://github.com/italiangrid/storm-puppet-module.git /storm-puppet-module
    cd /storm-puppet-module
fi
puppet module build
puppet module install ./pkg/cnafsd-storm-*.tar.gz --verbose

# Add the right enabled repository
puppet apply /assets/node/repos/${TARGET_RELEASE}.pp

# Setup node via Puppet
puppet apply /assets/node/setup.pp