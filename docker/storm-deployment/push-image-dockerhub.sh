#!/bin/bash
set -ex

tags=${tags:-"centos6"}

if [ -n "${DOCKERHUB_USERNAME}" ] && [ -n "${DOCKERHUB_PASSWORD}" ]; then

    docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}

    for t in ${tags}; do

        docker push italiangrid/storm-deployment:${t}

    done
fi
