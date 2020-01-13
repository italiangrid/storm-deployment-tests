#!/bin/bash

# install basics
yum install attr

mkdir /etc/grid-security
cp /setup/hostcert.pem /etc/grid-security/hostcert.pem
cp /setup/hostkey.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

puppet module install --force maestrodev-wget
puppet module install --force puppetlabs-stdlib

# Install needed modules
git clone git://github.com/cnaf/ci-puppet-modules.git /ci-puppet-modules
cd /ci-puppet-modules/modules

cd mwdevel_egi_trust_anchors
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_egi_trust_anchors-0.1.0.tar.gz
cd ..

cd mwdevel_umd_repo
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_umd_repo-0.1.0.tar.gz
cd ..

cd mwdevel_voms
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_voms-0.1.0.tar.gz
cd ..

cd mwdevel_test_vos
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_vos-0.1.0.tar.gz
cd ..

cd mwdevel_test_ca
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_test_ca-0.1.0.tar.gz

cd /

puppet apply --detailed-exitcodes /setup/manifest.pp

# check if errors occurred after puppet apply:
if [[ ( $? -eq 4 ) || ( $? -eq 6 ) ]]; then
  exit 1
fi

# install yaim core
yum clean all
yum install -y glite-yaim-core

yum install -y edg-mkgridmap lcas lcmaps lcas-lcmaps-gt4-interface