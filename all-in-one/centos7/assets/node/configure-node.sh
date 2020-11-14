#!/bin/bash

STORM_TARGET_RELEASE=${STORM_TARGET_RELEASE:-"stable"}
VOMS_TARGET_RELEASE=${VOMS_TARGET_RELEASE:-"stable"}
PKG_STORM_BRANCH=${PKG_STORM_BRANCH:-"none"}
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

# Install needed modules
puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl
puppet module install puppet-epel
puppet module install cnafsd-bdii
puppet module install cnafsd-umd4
puppet module install cnafsd-testvos
puppet module install cnafsd-testca
puppet module install cnafsd-sd_users

# Install storm puppet module
if [ -d "/storm-puppet-module" ] 
then
    echo "Directory /storm-puppet-module exists." 
    cd /storm-puppet-module
    rm -rf ./pkg
    puppet module uninstall cnafsd-storm
    puppet module build
    puppet module install ./pkg/cnafsd-storm-*.tar.gz --verbose
else
    puppet module install cnafsd-storm
fi

# Install storm lcmaps module
if [ -d "/puppet-lcmaps" ] 
then
    echo "Directory /puppet-lcmaps exists." 
    cd /puppet-lcmaps
    rm -rf ./pkg
    puppet module uninstall cnafsd-lcmaps
    puppet module build
    puppet module install ./pkg/cnafsd-lcmaps-*.tar.gz --verbose
else
    puppet module install cnafsd-lcmaps
fi

# Add the right enabled repositories
puppet apply /assets/node/repos/storm/${STORM_TARGET_RELEASE}.pp
puppet apply /assets/node/repos/voms/${VOMS_TARGET_RELEASE}.pp

if [ "$PKG_STORM_BRANCH" != "none" ]; then
    read -r -d '' PKG_STORM_PP_TEMPLATE << EOM
yumrepo { 'pkg-storm-BRANCH_NAME':
  ensure   => present,
  descr    => 'pkg-storm-BRANCH_NAME',
  baseurl  => 'https://ci.cloud.cnaf.infn.it/job/pkg.storm/job/BRANCH_NAME/lastSuccessfulBuild/artifact/artifacts/stage-area/centos7/',
  enabled  => 1,
  protect  => 1,
  priority => 1,
  gpgcheck => 0,
}
EOM
    PKG_STORM_PP=`echo "${PKG_STORM_PP_TEMPLATE}" | sed -e "s/BRANCH_NAME/${PKG_STORM_BRANCH}/g"`
    echo "${PKG_STORM_PP}" > /assets/node/repos/pkg-storm.pp
    puppet apply /assets/node/repos/pkg-storm.pp
fi

if [ "$PKG_VOMS_BRANCH" != "none" ]; then
    read -r -d '' PKG_VOMS_PP_TEMPLATE << EOM
yumrepo { 'pkg-voms-BRANCH_NAME':
  ensure   => present,
  descr    => 'pkg-voms-BRANCH_NAME',
  baseurl  => 'https://ci.cloud.cnaf.infn.it/job/pkg.voms/job/BRANCH_NAME/lastSuccessfulBuild/artifact/artifacts/stage-area/centos7/',
  enabled  => 1,
  protect  => 1,
  priority => 1,
  gpgcheck => 0,
}
EOM
    PKG_VOMS_PP=`echo "${PKG_VOMS_PP_TEMPLATE}" | sed -e "s/BRANCH_NAME/${PKG_VOMS_BRANCH}/g"`
    echo "${PKG_VOMS_PP}" > /assets/node/repos/pkg-voms.pp
    puppet apply /assets/node/repos/pkg-voms.pp
fi

# Setup node via Puppet
puppet apply /assets/node/setup.pp