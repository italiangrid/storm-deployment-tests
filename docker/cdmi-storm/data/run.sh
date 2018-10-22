#!/bin/bash
set -x

REDIS_HOSTNAME="${REDIS_HOSTNAME:-redis-server.example}"
CDMI_CLIENT_ID="${CDMI_CLIENT_ID:-838129a5-84ca-4dc4-bfd8-421ee317aabd}"
if [ -z ${CDMI_CLIENT_SECRET+x} ]; then echo "CDMI_CLIENT_SECRET is unset"; exit 1; fi

chmod +x deploy.sh

export CDMI_CLIENT_ID
export CDMI_CLIENT_SECRET

./deploy.sh
