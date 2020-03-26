#!/bin/bash

# Copy host certificate and key
mkdir -p /etc/grid-security
cp /setup/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /setup/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# Install YAIM tfnode profile
cp /setup/node-info.d/se_storm_tfnode /opt/glite/yaim/node-info.d/se_storm_tfnode

# Install needed modules
#puppet module install maestrodev-wget
#puppet module install --force puppetlabs-stdlib
puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl
puppet module install lcgdm-voms

# Install mwdevel puppet modules
git clone git://github.com/cnaf/ci-puppet-modules.git /ci-puppet-modules
cd /ci-puppet-modules/modules

#cd mwdevel_egi_trust_anchors
#puppet module build
#puppet module install ./pkg/mwdevel-mwdevel_egi_trust_anchors-0.1.0.tar.gz
#cd ..

cd mwdevel_umd_repo
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_umd_repo-0.1.0.tar.gz
cd ..

#cd mwdevel_voms
#puppet module build
#puppet module install ./pkg/mwdevel-mwdevel_voms-0.1.0.tar.gz
#cd ..

cd mwdevel_test_vos2
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_vos2-0.1.0.tar.gz
cd ..

cd mwdevel_test_ca
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_ca-0.1.0.tar.gz
cd ..

#cd mwdevel_infn_ca
#puppet module build
#puppet module install ./pkg/mwdevel-mwdevel_infn_ca-0.1.0.tar.gz
#cd ..

#cd mwdevel_terena_ca
#puppet module build
#puppet module install ./pkg/mwdevel-mwdevel_terena_ca-0.1.0.tar.gz
#cd ..