#!/bin/bash
set -ex
trap "exit 1" TERM

rm -rf /etc/storm/siteinfo
mkdir -p /etc/storm/siteinfo

cp -r ./siteinfo/* /etc/storm/siteinfo
