#!/bin/bash
set -ex
trap "exit 1" TERM

if [ -z ${UMD_RELEASE_RPM+x} ]; then echo "UMD_RELEASE_RPM is unset"; exit 1; fi

# install pgp-key
rpm --import http://repository.egi.eu/sw/production/umd/UMD-RPM-PGP-KEY
# install UMD repos
yum install -y ${UMD_RELEASE_RPM}

# We want to give more priority to the StoRM Repository than UMD
sed -i "s/priority=1/priority=2/" /etc/yum.repos.d/UMD-*-base.repo /etc/yum.repos.d/UMD-*-updates.repo

# clean
yum clean all
