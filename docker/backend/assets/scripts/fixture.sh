#!/bin/bash
set -ex
trap "exit 1" TERM

VERSION=$1

pushd .

# add SAs links
cd /storage/test.vo/
rm -rf testvo_to_testvo2
ln -s ../test.vo.2 testvo_to_testvo2

# metadata tests
TAPESA_ROOT="/storage/tape"
rm -rf $TAPESA_ROOT/test_metadata
mkdir -p $TAPESA_ROOT/test_metadata
echo "test online file" > $TAPESA_ROOT/test_metadata/diskonly.txt
setfattr -n user.storm.online -v "True" $TAPESA_ROOT/test_metadata/diskonly.txt
echo "test online and migrated file" > $TAPESA_ROOT/test_metadata/diskandtape.txt
setfattr -n user.storm.online -v "True" $TAPESA_ROOT/test_metadata/diskandtape.txt
setfattr -n user.storm.migrated -v "1" $TAPESA_ROOT/test_metadata/diskandtape.txt
echo "test nearline file" > $TAPESA_ROOT/test_metadata/tapeonly.txt
setfattr -n user.storm.online -v "False" $TAPESA_ROOT/test_metadata/tapeonly.txt
setfattr -n user.storm.migrated -v "1" $TAPESA_ROOT/test_metadata/tapeonly.txt
echo "test nearline file recalled" > $TAPESA_ROOT/test_metadata/recallinprogress.txt
setfattr -n user.storm.online -v "False" $TAPESA_ROOT/test_metadata/recallinprogress.txt
setfattr -n user.storm.migrated -v "1" $TAPESA_ROOT/test_metadata/recallinprogress.txt
setfattr -n user.TSMRecD -v "1495721014482" $TAPESA_ROOT/test_metadata/recallinprogress.txt
setfattr -n user.TSMRecR -v "0" $TAPESA_ROOT/test_metadata/recallinprogress.txt
setfattr -n user.TSMRecT -v "5b44eee4-de80-4d9c-b4ac-d4a205b4a9d4" $TAPESA_ROOT/test_metadata/recallinprogress.txt

popd