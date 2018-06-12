#!/bin/bash
set -ex
trap "exit 1" TERM

chmod +x clean-deployment_centos6.sh
./clean-deployment_centos6.sh