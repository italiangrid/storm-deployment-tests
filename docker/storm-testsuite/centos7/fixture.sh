#!/bin/bash

STORM_STORAGE_ROOT_DIR="${STORM_STORAGE_ROOT_DIR:-/storage}"

cp /usr/share/igi-test-ca/test0.p12 .
chmod 600 test0.p12
echo pass|voms-proxy-init -pwstdin --voms test.vo --cert test0.p12

STORAGE_SA_ROOT="${STORM_STORAGE_ROOT_DIR}/test.vo"
# StoRM WebDAV testsuite fixture
touch ${STORAGE_SA_ROOT}/get_test 
touch ${STORAGE_SA_ROOT}/rm_test
echo "1x2y" > ${STORAGE_SA_ROOT}/pget_test
touch ${STORAGE_SA_ROOT}/test_local_copy.copy
touch ${STORAGE_SA_ROOT}/tpc_test
touch ${STORAGE_SA_ROOT}/tpc_test_https
touch ${STORAGE_SA_ROOT}/tpc_test_oauth_https
touch ${STORAGE_SA_ROOT}/tpc_test_push;