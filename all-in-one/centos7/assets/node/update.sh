
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
puppet module build
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
