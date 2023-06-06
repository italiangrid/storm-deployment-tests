#!/bin/bash

# Add the right enabled repositories
puppet apply /assets/node/repos/storm/${STORM_TARGET_RELEASE}.pp
puppet apply /assets/node/repos/voms/${VOMS_TARGET_RELEASE}.pp

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

puppet module uninstall cnafsd-storm
# Install storm puppet module
if [ -d "/storm-puppet-module" ] 
then
    echo "Directory /storm-puppet-module exists."
    rm -rf /storm-puppet-module/pkg
else
    git clone --branch ${PUPPET_MODULE_BRANCH} https://github.com/italiangrid/storm-puppet-module.git /storm-puppet-module
fi
cd /storm-puppet-module
PDK_FRONTEND=noninteractive pdk build
puppet module install ./pkg/cnafsd-storm-*.tar.gz --verbose

# Install storm lcmaps module
#if [ -d "/puppet-lcmaps" ] 
#then
#    echo "Directory /puppet-lcmaps exists." 
#    cd /puppet-lcmaps
#    rm -rf ./pkg
#    puppet module uninstall cnafsd-lcmaps
#    puppet module build
#    puppet module install ./pkg/cnafsd-lcmaps-*.tar.gz --verbose
#else
#    puppet module install cnafsd-lcmaps
#fi

yum update -y