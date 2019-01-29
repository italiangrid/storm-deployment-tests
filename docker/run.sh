#!/bin/bash

outputDir="./output"

# Clear output directory
rm -rf ${outputDir}

# Create output directory
mkdir -p ${outputDir}/logs
mkdir -p ${outputDir}/var/log
mkdir -p ${outputDir}/etc
mkdir -p ${outputDir}/etc/sysconfig

# Stop if compose is running
docker-compose down
# Pull images from dockerhub
docker-compose pull

# Deployemnt test
docker network create example
docker-compose up --no-color storm-testsuite

# Save logs
docker-compose logs --no-color cdmi >${outputDir}/logs/cdmi.log
docker-compose logs --no-color storm >${outputDir}/logs/storm.log
docker-compose logs --no-color storm-testsuite >${outputDir}/logs/storm-testsuite.log
docker cp testsuite:/home/tester/storm-testsuite/reports ${outputDir}
docker cp storm:/var/log/storm ${outputDir}/var/log
docker cp storm:/etc/storm ${outputDir}/etc
docker cp storm:/etc/sysconfig/storm-webdav ${outputDir}/etc/sysconfig

# Exit Code
ts_ec=$(docker inspect testsuite -f '{{.State.ExitCode}}')

# Stop
docker-compose down

exit ${ts_ec}
