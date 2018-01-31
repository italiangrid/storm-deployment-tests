#!/bin/bash
set -e
[[ -n "${STORM_DEPLOYMENT_TEST_DEBUG}" ]] && set -x

TRAVIS_REPO_SLUG=${TRAVIS_REPO_SLUG:-italiangrid/storm-deployment-test}
TRAVIS_JOB_ID=${TRAVIS_JOB_ID:-0}
TRAVIS_JOB_NUMBER=${TRAVIS_JOB_NUMBER:-0}
REPORT_REPO_URL=${REPORT_REPO_URL:-}
MODE=${MODE:-clean}

docker --version
docker-compose --version

reports_dir=./reports

function tar_reports_and_logs(){
  if [ ! -d ${reports_dir} ]; then
    mkdir -p ${reports_dir}
  fi
  docker-compose logs --no-color docker-storm >${reports_dir}/storm.log
  docker-compose logs --no-color docker-storm-testsuite >${reports_dir}/storm-testsuite.log
  docker cp docker-storm-testsuite:/home/tester/storm-testsuite/reports ${reports_dir}
  tar cvzf reports.tar.gz reports
}

function upload_reports_and_logs() {
  if [ -r reports.tar.gz ]; then
    if [ -z "${REPORT_REPO_URL}" ]; then
      echo "Skipping report upload: REPORT_REPO_URL is undefined or empty"
      return 0
    fi

    REPORT_TARBALL_URL=${REPORT_REPO_URL}/${TRAVIS_REPO_SLUG}/${TRAVIS_JOB_ID}/${MODE}
    for file in ${reports_dir}
    do
      curl --user "${REPORT_REPO_USERNAME}:${REPORT_REPO_PASSWORD}" -T ${file} ${REPORT_TARBALL_URL}/${file}
    done

    echo "Reports for this deployment test can be accessed at:"
    echo ${REPORT_TARBALL_URL}
  fi
}
  
function cleanup(){
  retcod=$?
  if [ $retcod != 0 ]; then
    echo "Error! Cleanup..."
    if [ -d docker ]; then
      cd docker
      docker-compose stop
    fi
  fi
  exit $retcod
}

trap cleanup EXIT SIGINT SIGTERM SIGABRT

export MODE=${MODE}
cd docker
docker network create cnaf.infn.it
docker-compose up --abort-on-container-exit 

set +e

ts_ec=$(docker inspect docker-storm-testsuite -f '{{.State.ExitCode}}')

tar_reports_and_logs
set -e
upload_reports_and_logs
docker-compose stop

if [ ${ts_ec} != 0 ]; then
  exit 1
fi
