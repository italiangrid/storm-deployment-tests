#!/bin/bash
set -ex

tags=${tags:-"centos6 centos7"}

for t in ${tags}; do
    pushd ${t}
    docker build --pull=false --rm=true --no-cache=true -t italiangrid/storm-testsuite:${t} .
    popd
done
