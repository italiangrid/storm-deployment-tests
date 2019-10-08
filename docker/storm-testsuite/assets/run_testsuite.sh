#!/bin/bash
set -x

# Optional parameters
TESTSUITE="${TESTSUITE:-git://github.com/italiangrid/storm-testsuite.git}"
TESTSUITE_BRANCH="${TESTSUITE_BRANCH:-nightly}"
TESTSUITE_EXCLUDE="${TESTSUITE_EXCLUDE:-to-be-fixed}"
TESTSUITE_SUITE="${TESTSUITE_SUITE:-tests}"

VOMS_FAKE="${VOMS_FAKE:-false}"

STORM_BE_SYNC_PORT="${STORM_BE_SYNC_PORT:-8444}"
STORM_BE_HOST="${STORM_BE_HOST:-storm.example}"

CDMI_ENDPOINT="${CDMI_ENDPOINT:-cdmi-storm.example:8888}"
CDMI_CLIENT_ID="${CDMI_CLIENT_ID:-838129a5-84ca-4dc4-bfd8-421ee317aabd}"
IAM_USER_NAME="${IAM_USER_NAME:-storm_robot_user}"

STORM_STORAGE_ROOT_DIR="${STORM_STORAGE_ROOT_DIR:-/storage}"

CDMI_ADMIN_USERNAME=${CDMI_ADMIN_USERNAME:-restadmin}
CDMI_ADMIN_PASSWORD=${CDMI_ADMIN_PASSWORD:-restadmin}

DAV_HOST=${DAV_HOST:-storm-alias.example}
GFTP_HOST=${GFTP_HOST:-storm-alias.example}
GFTP_PORT=${GFTP_PORT:-2811}

# Mandatory parameters
if [ -z ${CDMI_CLIENT_SECRET+x} ]; then
    echo "CDMI_CLIENT_SECRET is unset";
fi
if [ -z ${IAM_USER_PASSWORD+x} ]; then
    echo "IAM_USER_PASSWORD is unset";
fi

# Build variables
VARIABLES="--variable backEndHost:$STORM_BE_HOST"
VARIABLES="$VARIABLES --variable cdmiEndpoint:$CDMI_ENDPOINT"
VARIABLES="$VARIABLES --variable cdmiClientId:$CDMI_CLIENT_ID"
VARIABLES="$VARIABLES --variable iamUserName:$IAM_USER_NAME"
VARIABLES="$VARIABLES --variable cdmiAdminUser:$CDMI_ADMIN_USERNAME"
VARIABLES="$VARIABLES --variable cdmiAdminPassword:$CDMI_ADMIN_PASSWORD"
VARIABLES="$VARIABLES --variable cdmiClientSecret:$CDMI_CLIENT_SECRET"
VARIABLES="$VARIABLES --variable iamUserPassword:$IAM_USER_PASSWORD"
VARIABLES="$VARIABLES --variable vomsFake:$VOMS_FAKE"
VARIABLES="$VARIABLES --variable storageAreaRoot:$STORM_STORAGE_ROOT_DIR"
VARIABLES="$VARIABLES --variable DAVHost:$DAV_HOST"
VARIABLES="$VARIABLES --variable globusEndpoint:$GFTP_HOST:$GFTP_PORT"

# Build exclude clause
if [ -z "$TESTSUITE_EXCLUDE" ]; then
  EXCLUDE=""
else
  EXCLUDE="--exclude $TESTSUITE_EXCLUDE"
fi

# Wait for StoRM services
WAIT_TIMEOUT=${WAIT_TIMEOUT:-600}

chmod +x /assets/scripts/wait-for-it.sh
/assets/scripts/wait-for-it.sh ${DAV_HOST}:8085 --timeout=${WAIT_TIMEOUT}
/assets/scripts/wait-for-it.sh ${STORM_BE_HOST}:8444 --timeout=${WAIT_TIMEOUT}

cd /home/tester/

if [ -d "storm-testsuite" ]; then
  cd storm-testsuite
else
  git clone $TESTSUITE --branch $TESTSUITE_BRANCH
  cd storm-testsuite
fi

robot --pythonpath .:lib $VARIABLES $EXCLUDE -d reports -s $TESTSUITE_SUITE tests
