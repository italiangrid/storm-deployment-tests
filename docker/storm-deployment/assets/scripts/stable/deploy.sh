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

# pre install script
sh ./pre-install.sh

source ./deploy.env

if [ -z ${STORM_REPO+x} ]; then echo "STORM_REPO is unset"; exit 1; fi
sh ./install-repo.sh ${STORM_REPO} storm-stable

# install
yum clean all
yum install -y emi-storm-backend-mp emi-storm-frontend-mp
yum update -y

fix_yaim

# deploy YAIM configuration files
sh ./configure.sh

# Sleep more in bdii init script to avoid issues on docker
sed -i 's/sleep 2/sleep 5/' /etc/init.d/bdii

# post operations
sh ./post-install.sh

# do yaim
/opt/glite/yaim/bin/yaim -c -s /etc/storm/siteinfo/storm.def -n se_storm_backend -n se_storm_frontend
