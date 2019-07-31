#!/bin/bash
set -ex
trap "exit 1" TERM

# We want to give more priority to the StoRM Repository than UMD
sed -i "s/priority=1/priority=2/" /etc/yum.repos.d/UMD-*-base.repo /etc/yum.repos.d/UMD-*-updates.repo