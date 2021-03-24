#!/bin/bash
set -ex

PLATFORM=${PLATFORM:-"centos7"}
OUTPUT_DIR=${OUTPUT_DIR:-"./output"}
COMPOSE_OPTS=${COMPOSE_OPTS:-"--no-ansi"}
TTY_OPTS="${TTY_OPTS:-}"

STORM_TARGET_RELEASE=${STORM_TARGET_RELEASE:-"stable"}
VOMS_TARGET_RELEASE=${VOMS_TARGET_RELEASE:-"stable"}
PKG_STORM_BRANCH=${PKG_STORM_BRANCH:-"none"}
PKG_STORM_PLATFORM=${PKG_STORM_PLATFORM:-"centos7java11"}
PKG_VOMS_BRANCH=${PKG_VOMS_BRANCH:-"none"}

# Clear output directory
rm -rf ${OUTPUT_DIR}

# Create output directory
mkdir -p ${OUTPUT_DIR}/compose-logs
mkdir -p ${OUTPUT_DIR}/var/log
mkdir -p ${OUTPUT_DIR}/etc/systemd/system/
mkdir -p ${OUTPUT_DIR}/etc/grid-security/

# Pull images from dockerhub
docker-compose ${COMPOSE_OPTS} pull

# Clear deployment and network
docker-compose ${COMPOSE_OPTS} down -v

ENV_VARS="-e STORM_TARGET_RELEASE=${STORM_TARGET_RELEASE} -e VOMS_TARGET_RELEASE=${VOMS_TARGET_RELEASE} -e PKG_STORM_BRANCH=${PKG_STORM_BRANCH} -e PKG_STORM_PLATFORM=${PKG_STORM_PLATFORM} -e PKG_VOMS_BRANCH=${PKG_VOMS_BRANCH}"

{

    # Deployment test

    # StoRM
    docker-compose ${COMPOSE_OPTS} up --no-color -d storm
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} ${ENV_VARS} storm sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} storm sh -c "sh /assets/services/configure-service.sh"

    set +e
    docker-compose ${COMPOSE_OPTS} up --no-color testsuite

    # Save testsuite reports dir
    docker cp testsuite:/home/tester/storm-testsuite/reports ${OUTPUT_DIR}

    # Save services logs
    docker cp storm:/var/log/storm ${OUTPUT_DIR}/var/log

    # Save configurations
    docker cp storm:/etc/storm ${OUTPUT_DIR}/etc
    docker cp storm:/etc/systemd/system/storm-backend-server.service.d ${OUTPUT_DIR}/etc/systemd/system
    docker cp storm:/etc/systemd/system/storm-webdav.service.d ${OUTPUT_DIR}/etc/systemd/system
    docker cp storm:/etc/grid-security/gridftp.conf ${OUTPUT_DIR}/etc/grid-security
    docker cp storm:/etc/sysconfig/storm-frontend-server ${OUTPUT_DIR}/etc/sysconfig

    # Exit Code
    ts_ec=$(docker inspect testsuite -f '{{.State.ExitCode}}')

} || {

    # Clear deployment and network
    docker-compose ${COMPOSE_OPTS} down -v
}

# Clear deployment and network
docker-compose ${COMPOSE_OPTS} down -v

set -e

exit ${ts_ec}
