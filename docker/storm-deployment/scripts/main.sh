#!/bin/bash
set -ex
trap "exit 1" TERM

if [ -z ${UPDATE_TO+x} ]; then echo "UPDATE_TO is unset"; exit 1; fi

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

if [ -z ${UPDATE_FROM+x} ]; then

  echo "UPDATE_FROM is unset - it's a clean deployment";

else

  cd ${UPDATE_FROM}
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

cd ${UPDATE_TO}
sh ./deploy.sh
cd ..

sh ./fixture.sh ${UPDATE_TO}

/usr/libexec/storm-info-provider get-report-json
cat /etc/storm/info-provider/site-report.json
