#!/bin/bash
set -ex

stop_active_containers () {

    # get params
    network_name=$1
    # get active containers names
    echo "getting active containers ... "
    active_containers=`docker network inspect ${network_name} --format='{{range .Containers}}{{.Name}} {{end}}'`
    echo "stopping ${active_containers} ..."
    docker stop ${active_containers}
    echo "active containers have been stopped."
}

delete_containers () {

    # get params
    containers=$1
    # delete containers
    echo "deleting ${containers} ..."
    docker rm -f ${containers} || true
    echo "deleted."
}

outputDir="./output"

ALL_CONTAINERS="testsuite cdmi webdav gridftp frontend backend redis trust"

PLATFORM=${PLATFORM:-centos7}
TARGET_RELEASE=${TARGET_RELEASE:-nightly}

COMPOSE_FILE="docker-compose-${PLATFORM}.yml"
COMPOSE_OPTS="--no-ansi -f ${COMPOSE_FILE}"

TTY_OPTS="${TTY_OPTS:-}"

# Clear output directory
rm -rf ${outputDir}

# Create output directory
mkdir -p ${outputDir}/compose-logs
mkdir -p ${outputDir}/var/log
mkdir -p ${outputDir}/etc
mkdir -p ${outputDir}/etc/sysconfig

# Stop if compose is running
{ 
    docker-compose ${COMPOSE_OPTS} down -v

} || {

    # Probably there are still active nodeS
    stop_active_containers "test.example"
    docker-compose ${COMPOSE_OPTS} down -v
}
# Pull images from dockerhub
docker-compose ${COMPOSE_OPTS} pull

# Deployment test
docker-compose ${COMPOSE_OPTS} up --no-color -d backend
docker-compose ${COMPOSE_OPTS} up --no-color -d frontend
docker-compose ${COMPOSE_OPTS} up --no-color -d gridftp
docker-compose ${COMPOSE_OPTS} up --no-color -d webdav

docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /assets/configure-node.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} frontend sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-node.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} gridftp sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-node.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} webdav sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-node.sh"

docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} backend sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /assets/configure-service.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} frontend sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-service.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} gridftp sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-service.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} webdav sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /node/configure-service.sh"

docker-compose ${COMPOSE_OPTS} up --no-color -d cdmi
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} cdmi sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /assets/configure-node.sh"
docker-compose ${COMPOSE_OPTS} exec ${TTY_OPTS} cdmi sh -c "TARGET_RELEASE=${TARGET_RELEASE} sh /assets/configure-service.sh"

set +e
docker-compose ${COMPOSE_OPTS} up --no-color testsuite

# Save docker-compose logs
docker-compose ${COMPOSE_OPTS} logs --no-color trust >${outputDir}/compose-logs/trust.log
docker-compose ${COMPOSE_OPTS} logs --no-color cdmi >${outputDir}/compose-logs/cdmi.log
docker-compose ${COMPOSE_OPTS} logs --no-color backend >${outputDir}/compose-logs/backend.log
docker-compose ${COMPOSE_OPTS} logs --no-color webdav >${outputDir}/compose-logs/webdav.log
docker-compose ${COMPOSE_OPTS} logs --no-color frontend >${outputDir}/compose-logs/frontend.log
docker-compose ${COMPOSE_OPTS} logs --no-color gridftp >${outputDir}/compose-logs/gridftp.log
docker-compose ${COMPOSE_OPTS} logs --no-color testsuite >${outputDir}/compose-logs/testsuite.log

# Save testsuite reports dir
docker cp testsuite:/home/tester/storm-testsuite/reports ${outputDir}

# Save services logs
docker cp backend:/var/log/storm ${outputDir}/var/log
docker cp webdav:/var/log/storm ${outputDir}/var/log
docker cp gridftp:/var/log/storm ${outputDir}/var/log
docker cp frontend:/var/log/storm ${outputDir}/var/log

# Save configurations
docker cp backend:/etc/storm ${outputDir}/etc
docker cp webdav:/etc/storm ${outputDir}/etc
docker cp webdav:/etc/sysconfig/storm-webdav ${outputDir}/etc/sysconfig
docker cp gridftp:/etc/storm ${outputDir}/etc
docker cp gridftp:/etc/gridftp.conf ${outputDir}/etc
docker cp frontend:/etc/storm ${outputDir}/etc
docker cp frontend:/etc/sysconfig/storm-frontend-server ${outputDir}/etc/sysconfig

# Exit Code
ts_ec=$(docker inspect testsuite -f '{{.State.ExitCode}}')

# Stop all containers and remove them
stop_active_containers "test.example"
# Delete all containers
delete_containers ${ALL_CONTAINERS}

# Clear deployment and network
docker-compose ${COMPOSE_OPTS} down -v


set -e

exit ${ts_ec}
