#!/bin/bash

outputDir="./output"

# Clear output directory
rm -rf ${outputDir}

# Create output directory
mkdir -p ${outputDir}/compose-logs
mkdir -p ${outputDir}/var/log
mkdir -p ${outputDir}/etc
mkdir -p ${outputDir}/etc/sysconfig

# Stop if compose is running
docker-compose down
# Pull images from dockerhub
docker-compose pull

# Deployemnt test
docker network create example
docker-compose up --no-color -d storm
docker-compose logs -f cdmi-storm redis-server trust storm &
docker-compose up --no-color storm-testsuite
kill %1 #kill the first background progress: tail

# Save logs
docker-compose logs --no-color trust >${outputDir}/compose-logs/trust.log
docker-compose logs --no-color cdmi-storm >${outputDir}/compose-logs/cdmi-storm.log
docker-compose logs --no-color redis-server >${outputDir}/compose-logs/redis-server.log
docker-compose logs --no-color storm >${outputDir}/compose-logs/storm.log
docker-compose logs --no-color storm-testsuite >${outputDir}/compose-logs/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports ${outputDir}
docker cp storm:/var/log/storm ${outputDir}/var/log
docker cp storm:/etc/storm ${outputDir}/etc
docker cp storm:/etc/sysconfig/storm-webdav ${outputDir}/etc/sysconfig

# Exit Code
ts_ec=$(docker inspect testsuite -f '{{.State.ExitCode}}')

# Stop
docker-compose down

exit ${ts_ec}