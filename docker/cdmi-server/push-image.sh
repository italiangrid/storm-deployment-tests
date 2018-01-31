#!/bin/bash
set -ex

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then
  docker tag italiangrid/cdmi-server ${DOCKER_REGISTRY_HOST}/italiangrid/cdmi-server
  docker push ${DOCKER_REGISTRY_HOST}/italiangrid/cdmi-server
fi