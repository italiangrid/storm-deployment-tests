#!/bin/bash

# Copy host certificate and key
mkdir -p /etc/grid-security
cp /assets/node/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /assets/node/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Install StoRM prerequisites:
yum install -y attr

# Install needed modules
puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl
puppet module install lcgdm-voms
puppet module install cnafsd-bdii

# Install mwdevel puppet modules
git clone git://github.com/cnaf/ci-puppet-modules.git /ci-puppet-modules
cd /ci-puppet-modules/modules

cd mwdevel_umd_repo
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_umd_repo-0.1.0.tar.gz
cd ..

cd mwdevel_test_vos2
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_vos2-0.1.0.tar.gz
cd ..

cd mwdevel_test_ca
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_ca-0.1.0.tar.gz
cd ..

# Install storm puppet module
if [ -d "/storm-puppet-module" ] 
then
    echo "Directory /storm-puppet-module exists." 
    cd /storm-puppet-module
    rm -rf ./pkg
    puppet module uninstall cnafsd-storm
else
    echo "Directory /storm-puppet-module does not exists."
    git clone https://github.com/italiangrid/storm-puppet-module.git -b ${STORM_PUPPET_MODULE_BRANCH} /storm-puppet-module
    cd /storm-puppet-module
fi
puppet module build
puppet module install ./pkg/cnafsd-storm-*.tar.gz

# Add the right enabled repository
puppet apply /assets/node/repos/${TARGET_RELEASE}.pp

# Setup node via Puppet
puppet apply /assets/node/setup.pp