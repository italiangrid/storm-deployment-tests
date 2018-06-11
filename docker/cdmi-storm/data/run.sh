#!/bin/bash
set -x

MODE="${MODE:-clean}"
PLATFORM="${PLATFORM:-centos6}"
REDIS_HOSTNAME="${REDIS_HOSTNAME:-localhost}"
CDMI_CLIENT_ID="${CDMI_CLIENT_ID:-838129a5-84ca-4dc4-bfd8-421ee317aabd}"
if [ -z ${CDMI_CLIENT_SECRET+x} ]; then echo "CDMI_CLIENT_SECRET is unset"; exit 1; fi

DEPLOYMENT_SCRIPT="${MODE}-deployment_${PLATFORM}.sh"
chmod +x ${DEPLOYMENT_SCRIPT}

export CDMI_CLIENT_ID
export CDMI_CLIENT_SECRET

./$DEPLOYMENT_SCRIPT
