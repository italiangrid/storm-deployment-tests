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

# Install needed modules

# Added because version 7 is not (really?) supported by saz/sudo
puppet module install --force puppetlabs-stdlib --version 6.6.0

puppet module install puppetlabs-ntp
puppet module install puppet-fetchcrl
puppet module install puppet-epel
puppet module install cnafsd-bdii
puppet module install cnafsd-umd4
puppet module install cnafsd-voms
puppet module install cnafsd-testca
puppet module install cnafsd-sdds_users

puppet module install cnafsd-storm
puppet module install cnafsd-lcmaps

# Add only stable repo enabled
puppet apply /assets/node/repos/storm/stable.pp
puppet apply /assets/node/repos/voms/stable.pp

if [ "$PKG_STORM_BRANCH" != "none" ]; then
    read -r -d '' PKG_STORM_PP_TEMPLATE << EOM
yumrepo { 'pkg-storm-BRANCH_NAME':
  ensure   => present,
  descr    => 'pkg-storm-BRANCH_NAME',
  baseurl  => 'https://ci.cloud.cnaf.infn.it/job/pkg.storm/job/BRANCH_NAME/lastSuccessfulBuild/artifact/artifacts/stage-area/PKG_STORM_PLATFORM/',
  enabled  => 1,
  protect  => 1,
  priority => 1,
  gpgcheck => 0,
}
EOM
    PKG_STORM_PP=`echo "${PKG_STORM_PP_TEMPLATE}" | sed -e "s/BRANCH_NAME/${PKG_STORM_BRANCH}/g" | sed -e "s/PKG_STORM_PLATFORM/${PKG_STORM_PLATFORM}/g"`
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