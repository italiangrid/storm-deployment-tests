#!/bin/bash
set -ex

if [ -n "${DOCKERHUB_USERNAME}" ] && [ -n "${DOCKERHUB_PASSWORD}" ]; then

    docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}
    docker push italiangrid/cdmi-storm

fi
