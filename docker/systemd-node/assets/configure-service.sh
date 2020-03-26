#!/bin/bash

echo "STORM_PUPPET_MODULE_BRANCH=${STORM_PUPPET_MODULE_BRANCH}"
echo "TARGET_RELEASE=${TARGET_RELEASE}"
echo "COMPONENT=${COMPONENT}"

# Copy siteinfo directory
mkdir -p /etc/storm
cp -R /assets/siteinfo /etc/storm

# Install storm puppet module
git clone https://github.com/enricovianello/storm-puppet-module.git -b ${STORM_PUPPET_MODULE_BRANCH} /storm-puppet-module
cd /storm-puppet-module
puppet module build
puppet module install ./pkg/mwdevel-storm-0.1.0.tar.gz

# Setup node via Puppet
puppet apply /assets/setup.pp

# Run YAIM
/opt/glite/yaim/bin/yaim -d 12 -c -s /etc/storm/siteinfo/storm.def -n se_storm_tfnode

# Add the right enabled repository
puppet apply /assets/repos/${TARGET_RELEASE}.pp

# Install StoRM services
puppet apply --detailed-exitcodes /assets/${COMPONENT}/manifest.pp