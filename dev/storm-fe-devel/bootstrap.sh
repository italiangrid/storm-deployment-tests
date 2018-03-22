#!/bin/bash
set -ex

sudo mkdir -p /etc/grid-security/grimapdir
sudo cp -r /gridmapdir/* /etc/grid-security/
sudo cp /certs/hostcert.pem /etc/grid-security/storm/
sudo cp /certs/hostkey.pem /etc/grid-security/storm/
sudo chown -R storm:storm /etc/grid-security/storm

git clone /code storm-frontend
rpm --eval '%{configure}' > storm-frontend/do-configure.sh
chmod +x storm-frontend/do-configure.sh
pushd storm-frontend
./do-configure.sh

if [ -n "${STORM_FE_BUILD}" ]; then
  make 
  sudo make install
fi

popd

sleep infinity
