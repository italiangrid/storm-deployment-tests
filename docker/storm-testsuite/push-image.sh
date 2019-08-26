#!/bin/bash
set -ex

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then

    docker tag italiangrid/storm-testsuite ${DOCKER_REGISTRY_HOST}/italiangrid/storm-testsuite
    docker push ${DOCKER_REGISTRY_HOST}/italiangrid/storm-testsuite

fi
