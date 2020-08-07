#!/bin/bash
set -ex

PLATFORM=${PLATFORM:-"centos7"}
OUTPUT_DIR=${OUTPUT_DIR:-"./output"}
COMPOSE_OPTS=${COMPOSE_OPTS:-"--no-ansi"}
TTY_OPTS="${TTY_OPTS:-}"

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

    # Backend
    docker-compose ${COMPOSE_OPTS} up --no-color -d backend
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "sh /assets/node/configure-service.sh"

    # Frontend
    docker-compose ${COMPOSE_OPTS} up --no-color -d frontend
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} frontend sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} frontend sh -c "sh /assets/node/configure-service.sh"

    # GridFTP
    docker-compose ${COMPOSE_OPTS} up --no-color -d gridftp
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} gridftp sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} gridftp sh -c "sh /assets/node/configure-service.sh"

    # WebDAV
    docker-compose ${COMPOSE_OPTS} up --no-color -d webdav
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} webdav sh -c "sh /assets/node/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} webdav sh -c "sh /assets/node/configure-service.sh"

    set +e
    docker-compose ${COMPOSE_OPTS} up --no-color testsuite

    # Save testsuite reports dir
    docker cp testsuite:/home/tester/storm-testsuite/reports ${OUTPUT_DIR}

    # Save services logs
    docker cp backend:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp webdav:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp gridftp:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp frontend:/var/log/storm ${OUTPUT_DIR}/var/log

    # Save configurations
    docker cp backend:/etc/storm ${OUTPUT_DIR}/etc
    docker cp backend:/etc/systemd/system/storm-backend-server.service.d ${OUTPUT_DIR}/etc/systemd/system
    docker cp webdav:/etc/storm ${OUTPUT_DIR}/etc
    docker cp webdav:/etc/systemd/system/storm-webdav.service.d ${OUTPUT_DIR}/etc/systemd/system
    docker cp gridftp:/etc/storm ${OUTPUT_DIR}/etc
    docker cp gridftp:/etc/gridftp.conf ${OUTPUT_DIR}/etc
    docker cp frontend:/etc/storm ${OUTPUT_DIR}/etc
    docker cp frontend:/etc/sysconfig/storm-frontend-server ${OUTPUT_DIR}/etc/sysconfig

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
