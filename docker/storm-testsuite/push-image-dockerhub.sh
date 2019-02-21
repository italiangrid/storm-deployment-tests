#!/bin/bash
set -ex

tags=${tags:-"centos6 centos7"}

for t in ${tags}; do

  echo "Pushing italiangrid/storm-testsuite:${t} on dockerhub ..."
  docker push italiangrid/storm-testsuite:${t}

done
