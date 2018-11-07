#!/bin/bash
set -ex
trap "exit 1" TERM

REPO_URL=$1
REPO_NAME=$2

if [ -z ${REPO_URL+x} ]; then echo "REPO_URL is unset"; exit 1; fi
if [ -z ${REPO_NAME+x} ]; then echo "REPO_NAME is unset"; exit 1; fi

# install the storm repo
wget --no-check-certificate ${REPO_URL} -O /etc/yum.repos.d/${REPO_NAME}.repo

# clean
yum clean all
