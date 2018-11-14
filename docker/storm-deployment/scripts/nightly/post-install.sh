#!/bin/bash
set -ex
trap "exit 1" TERM

# StoRM WebDAV needs to know what host has not to be considered as a 3rd-party copy
echo "\nSTORM_WEBDAV_HOSTNAME_0=\"storm.example\"\n" >> /etc/sysconfig/storm-webdav
