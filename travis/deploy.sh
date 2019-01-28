#!/bin/bash
set -e
[[ -n "${STORM_DEPLOYMENT_TEST_DEBUG}" ]] && set -x

TRAVIS_REPO_SLUG=${TRAVIS_REPO_SLUG:-italiangrid/storm-deployment-tests}
TRAVIS_JOB_ID=${TRAVIS_JOB_ID:-0}
TRAVIS_JOB_NUMBER=${TRAVIS_JOB_NUMBER:-0}
REPORT_REPO_URL=${REPORT_REPO_URL:-}
UPGRADE_FROM=${UPGRADE_FROM:-stable}

docker --version
docker-compose --version

reports_dir=./output

function tar_reports_and_logs(){
  tar cvzf reports.tar.gz ${reports_dir}
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

export UPGRADE_FROM=${UPGRADE_FROM}
cd docker
sh run.sh

set +e

ts_ec=$(docker inspect testsuite -f '{{.State.ExitCode}}')

tar_reports_and_logs
set -e
upload_reports_and_logs

if [ ${ts_ec} != 0 ]; then
  exit 1
fi
