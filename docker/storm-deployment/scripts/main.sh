#!/bin/bash

fix_yaim () {
  # avoid starting frontend server
  sed -i -e '/\/sbin\/service storm-frontend-server start/c\\#\/sbin\/service storm-frontend-server start' /opt/glite/yaim/functions/local/config_storm_frontend

  # avoid ntp check
  echo "config_ntp () {"> /opt/glite/yaim/functions/local/config_ntp
  echo "return 0">> /opt/glite/yaim/functions/local/config_ntp
  echo "}">> /opt/glite/yaim/functions/local/config_ntp
}

set -ex
trap "exit 1" TERM

if [ -z ${UMD_RELEASE_RPM+x} ]; then echo "UMD_RELEASE_RPM is unset"; exit 1; fi
if [ -z ${STORM_REPO+x} ]; then echo "STORM_REPO is unset"; exit 1; fi

# install UMD repositories
sh "./install-umd-repos.sh" ${UMD_RELEASE_RPM}

# install a list of repositories
if [ -z ${INSTALLED_REPOS+x} ]; then
  echo "nothing to install";
else
  for repo in $(echo $INSTALLED_REPOS | sed "s/,/ /g")
  do
    repo_name=$(echo ${repo} | awk -F/ '{printf $NF}')
    echo "Install repo '${repo}' in '${repo_name}' ..."
    sh "./install-repo.sh" ${repo} ${repo_name}
  done
fi

# add some users
adduser -r storm

# install
yum clean all
yum install -y emi-storm-backend-mp emi-storm-frontend-mp emi-storm-globus-gridftp-mp storm-webdav

fix_yaim

# install yaim configuration
sh "./install-yaim-configuration.sh" "clean"

# Sleep more avoid issues on docker
#sed -i 's/sleep 20/sleep 30/' /etc/init.d/storm-backend-server

# Sleep more in bdii init script to avoid issues on docker
sed -i 's/sleep 2/sleep 5/' /etc/init.d/bdii

# do yaim
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend -n se_storm_frontend -n se_storm_gridftp -n se_storm_webdav

# install StoRM test repository
sh "./install-repo.sh" ${STORM_REPO} storm-test

# update
yum clean all
yum update -y

if [ $? != 0 ]; then
    echo "Problem occurred while updating the system!"
    exit 1
fi

sh "./post-update.sh"

fix_yaim

# Sleep more avoid issues on docker
#sed -i 's/sleep 20/sleep 30/' /etc/init.d/storm-backend-server

# Sleep more in bdii init script to avoid issues on docker
#sed -i 's/sleep 2/sleep 5/' /etc/init.d/bdii

# re-install yaim configuration
sh "./install-yaim-configuration.sh" "update"

# run post-installation config script
sh "./post-config-setup.sh" "update"

# do yaim
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend -n se_storm_frontend -n se_storm_gridftp -n se_storm_webdav
