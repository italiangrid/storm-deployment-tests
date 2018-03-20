#!/bin/bash
set -ex

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
  docker push ${DOCKER_REGISTRY_HOST}/italiangrid/storm-testsuite
fi
