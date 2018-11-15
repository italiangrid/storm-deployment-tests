#!/bin/bash
set -ex
trap "exit 1" TERM

if [ -z ${TARGET_RELEASE+x} ]; then
    echo "TARGET_RELEASE is unset - 'nightly' will be used as target";
    TARGET_RELEASE="nightly"
fi

# install UMD repositories
sh ./install-umd-repos.sh

# add storm user
adduser -r storm

# update all
yum clean all
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

sh ./fixture.sh ${TARGET_RELEASE}

/usr/libexec/storm-info-provider get-report-json
cat /etc/storm/info-provider/site-report.json
