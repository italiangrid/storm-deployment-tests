#!/bin/bash

echo "TARGET_RELEASE=${TARGET_RELEASE}"

# Install storm puppet module
git clone https://github.com/enricovianello/storm-puppet-module.git /storm-puppet-module
cd /storm-puppet-module
puppet module build
puppet module install ./pkg/mwdevel-storm-0.1.0.tar.gz

# install YAIM tfnode profile
cp /assets/node-info.d/se_storm_tfnode /opt/glite/yaim/node-info.d/se_storm_tfnode
# copy siteinfo directory
mkdir -p /etc/storm
cp -R /assets/siteinfo /etc/storm
# run YAIM
/opt/glite/yaim/bin/yaim -d 12 -c -s /etc/storm/siteinfo/storm.def -n se_storm_tfnode

# Add the right enabled repository
puppet apply /assets/repos/${TARGET_RELEASE}.pp

# Install StoRM services
puppet apply /assets/manifest.pp