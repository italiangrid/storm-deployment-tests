#!/bin/bash
set -ex
trap "exit 1" TERM

STORM_UID=${STORM_UID:-991}
STORM_GID=${STORM_GID:-991}

echo "UPGRADE_FROM = ${UPGRADE_FROM}"
echo "TARGET_RELEASE = ${TARGET_RELEASE}"
echo "STORM_UID = ${STORM_UID}"
echo "STORM_GID = ${STORM_GID}"

if [ -z ${TARGET_RELEASE+x} ]; then
    echo "TARGET_RELEASE is unset - 'nightly' will be used as target";
    TARGET_RELEASE="nightly"
fi

# add storm user
groupadd -g ${STORM_GID} storm
useradd -u ${STORM_UID} -g ${STORM_GID} storm

# install UMD repositories
sh ./install-umd-repos.sh

# update all
yum clean all
yum install -y ntp
yum update -y

if [ $? != 0 ]; then
    echo "Problem occurred while updating the system!"
    exit 1
fi

if [ -z ${UPGRADE_FROM} ]; then

  echo "UPGRADE_FROM is empty or unset - it's a clean deployment";

else

  cd ${UPGRADE_FROM}
  sh ./deploy.sh
  cd ..

  # update all
  yum clean all
  yum update -y

  if [ $? != 0 ]; then
      echo "Problem occurred while updating the system!"
      exit 1
  fi

fi

cd ${TARGET_RELEASE}
sh ./deploy.sh
cd ..