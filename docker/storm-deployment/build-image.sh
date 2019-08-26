#!/bin/bash
set -ex
tags=${tags:-"centos6"}

for t in ${tags}; do
    docker build -t italiangrid/storm-deployment:${t} -f Dockerfile.${t} .
done
