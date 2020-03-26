#!/bin/bash
set -ex

# stop_active_containers () {

#     # get params
#     network_name=$1
#     # get active containers names
#     echo "getting active containers ... "
#     active_containers=`docker network inspect ${network_name} --format='{{range .Containers}}{{.Name}} {{end}}'`
#     echo "stopping ${active_containers} ..."
#     docker stop ${active_containers}
#     echo "active containers have been stopped."
# }

# delete_containers () {

#     # get params
#     containers=$1
#     # delete containers
#     echo "deleting ${containers} ..."
#     docker rm -f ${containers} || true
#     echo "deleted."
# }

#ALL_CONTAINERS="testsuite cdmi webdav gridftp frontend backend redis trust"

PLATFORM=${PLATFORM:-"centos7"}
ENV_FILE=${ENV_FILE:-".env"}
OUTPUT_DIR=${OUTPUT_DIR:-"./output"}
COMPOSE_OPTS=${COMPOSE_OPTS:-"--no-ansi --env-file=${ENV_FILE}"}
TTY_OPTS="${TTY_OPTS:-}"

# Clear output directory
rm -rf ${OUTPUT_DIR}

# Create output directory
mkdir -p ${OUTPUT_DIR}/compose-logs
mkdir -p ${OUTPUT_DIR}/var/log
mkdir -p ${OUTPUT_DIR}/etc
mkdir -p ${OUTPUT_DIR}/etc/sysconfig

# Pull images from dockerhub
docker-compose ${COMPOSE_OPTS} pull

# Clear deployment and network
docker-compose ${COMPOSE_OPTS} down -v

{

    # Deployment test
    docker-compose ${COMPOSE_OPTS} up --no-color -d backend
    docker-compose ${COMPOSE_OPTS} up --no-color -d frontend
    docker-compose ${COMPOSE_OPTS} up --no-color -d gridftp
    docker-compose ${COMPOSE_OPTS} up --no-color -d webdav

    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "sh /assets/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "sh /assets/configure-service.sh"

    docker-compose ${COMPOSE_OPTS} up --no-color -d cdmi
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} cdmi sh -c "sh /assets/configure-node.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} cdmi sh -c "sh /assets/configure-service.sh"

    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} frontend sh -c "sh /assets/configure-service.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} gridftp sh -c "sh /assets/configure-service.sh"
    docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} webdav sh -c "sh /assets/configure-service.sh"

    set +e
    docker-compose ${COMPOSE_OPTS} up --no-color testsuite

    # Save docker-compose logs
    docker-compose ${COMPOSE_OPTS} logs --no-color trust >${OUTPUT_DIR}/compose-logs/trust.log
    docker-compose ${COMPOSE_OPTS} logs --no-color cdmi >${OUTPUT_DIR}/compose-logs/cdmi.log
    docker-compose ${COMPOSE_OPTS} logs --no-color backend >${OUTPUT_DIR}/compose-logs/backend.log
    docker-compose ${COMPOSE_OPTS} logs --no-color webdav >${OUTPUT_DIR}/compose-logs/webdav.log
    docker-compose ${COMPOSE_OPTS} logs --no-color frontend >${OUTPUT_DIR}/compose-logs/frontend.log
    docker-compose ${COMPOSE_OPTS} logs --no-color gridftp >${OUTPUT_DIR}/compose-logs/gridftp.log
    docker-compose ${COMPOSE_OPTS} logs --no-color testsuite >${OUTPUT_DIR}/compose-logs/testsuite.log

    # Save testsuite reports dir
    docker cp testsuite:/home/tester/storm-testsuite/reports ${OUTPUT_DIR}

    # Save services logs
    docker cp backend:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp webdav:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp gridftp:/var/log/storm ${OUTPUT_DIR}/var/log
    docker cp frontend:/var/log/storm ${OUTPUT_DIR}/var/log

    # Save configurations
    docker cp backend:/etc/storm ${OUTPUT_DIR}/etc
    docker cp webdav:/etc/storm ${OUTPUT_DIR}/etc
    docker cp webdav:/etc/sysconfig/storm-webdav ${OUTPUT_DIR}/etc/sysconfig
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
