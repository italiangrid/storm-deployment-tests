#!/bin/bash

echo "TARGET_RELEASE=${TARGET_RELEASE}"

# Install host certificate and key
mkdir /etc/grid-security
cp /node/certificates/star.test.example.cert.pem /etc/grid-security/hostcert.pem
cp /node/certificates/star.test.example.key.pem /etc/grid-security/hostkey.pem
chmod 644 /etc/grid-security/hostcert.pem
chmod 400 /etc/grid-security/hostkey.pem

# clean all
yum clean all

# Install attr
yum install -y attr

# Install puppet and base modules
rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm
yum install -y puppet
puppet module install maestrodev-wget
#puppet module install --force puppetlabs-stdlib
puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl

# Install used mwdevel puppet modules
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
cd ..

cd mwdevel_infn_ca
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_infn_ca-0.1.0.tar.gz
cd ..

cd mwdevel_terena_ca
puppet module build
puppet module install ./pkg/mwdevel-mwdevel_terena_ca-0.1.0.tar.gz
cd ..

# Setup node
puppet apply --detailed-exitcodes /node/setup/manifest.pp

# Install storm puppet module
git clone https://github.com/enricovianello/storm-puppet-module.git /storm-puppet-module
cd /storm-puppet-module
puppet module build
puppet module install ./pkg/mwdevel-storm-0.1.0.tar.gz

# Install yaim core
yum install -y glite-yaim-core
# Install YAIM tfnode profile
cp /node/node-info.d/se_storm_tfnode /opt/glite/yaim/node-info.d/se_storm_tfnode
# Copy siteinfo directory
mkdir -p /etc/storm
cp -R /node/siteinfo /etc/storm
# Install tfnode profile's needed rpms
yum install -y edg-mkgridmap lcas lcmaps lcas-lcmaps-gt4-interface
# Run YAIM
/opt/glite/yaim/bin/yaim -d 12 -c -s /etc/storm/siteinfo/storm.def -n se_storm_tfnode

# Add the right enabled repository
puppet apply /node/repos/${TARGET_RELEASE}.pp