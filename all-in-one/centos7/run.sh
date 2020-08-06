#!/bin/bash
set -ex

PLATFORM=${PLATFORM:-"centos7"}
OUTPUT_DIR=${OUTPUT_DIR:-"./output"}
COMPOSE_OPTS=${COMPOSE_OPTS:-"--no-ansi"}
TTY_OPTS="${TTY_OPTS:-}"

TARGET_RELEASE=${TARGET_RELEASE:-"beta"}
STORM_PUPPET_MODULE_BRANCH=${STORM_PUPPET_MODULE_BRANCH:-"develop"}

COMPOSE_ENV_VARS="-e TARGET_RELEASE=${TARGET_RELEASE} -e STORM_PUPPET_MODULE_BRANCH=${STORM_PUPPET_MODULE_BRANCH}"

# Clear output directory
rm -rf ${OUTPUT_DIR}

# Create output directory
mkdir -p ${OUTPUT_DIR}/compose-logs
mkdir -p ${OUTPUT_DIR}/var/log
mkdir -p ${OUTPUT_DIR}/etc/systemd/system/

# Pull images from dockerhub
docker-compose ${COMPOSE_OPTS} pull

# Clear deployment and network
docker-compose ${COMPOSE_OPTS} down -v

{

    # Deployment test

    # StoRM
    docker-compose ${COMPOSE_OPTS} up --no-color -d storm
    docker-compose ${COMPOSE_OPTS} ${COMPOSE_ENV_VARS} exec ${TTY_OPTS} storm sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} storm sh -c "sh /assets/node/configure-service.sh"

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
    docker cp storm:/etc/gridftp.conf ${OUTPUT_DIR}/etc
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
