#!/bin/bash
set -ex

tags=${tags:-"centos6 centos7"}

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then

    for t in ${tags}; do

        docker tag italiangrid/storm-testsuite:${t} ${DOCKER_REGISTRY_HOST}/italiangrid/storm-testsuite:${t}
        docker push ${DOCKER_REGISTRY_HOST}/italiangrid/storm-testsuite:${t}

    done
fi
