#!/bin/bash
set -ex
trap "exit 1" TERM

pushd .

# add SAs links
cd /storage/test.vo/
rm -rf testvo_to_testvo2
ln -s ../test.vo.2 testvo_to_testvo2
chown -h storm:storm testvo_to_testvo2

# metadata tests
TAPESA_ROOT="/storage/tape"
TEST_DIRECTORY="$TAPESA_ROOT/test_metadata"
rm -rf $TEST_DIRECTORY
install -d -m 0750 -o storm -g storm $TEST_DIRECTORY

echo "test online file" > $TEST_DIRECTORY/diskonly.txt
setfattr -n user.storm.online -v "True" $TEST_DIRECTORY/diskonly.txt

echo "test online and migrated file" > $TEST_DIRECTORY/diskandtape.txt
setfattr -n user.storm.online -v "True" $TEST_DIRECTORY/diskandtape.txt
setfattr -n user.storm.migrated -v "1" $TEST_DIRECTORY/diskandtape.txt

echo "test nearline file" > $TEST_DIRECTORY/tapeonly.txt
setfattr -n user.storm.online -v "False" $TEST_DIRECTORY/tapeonly.txt
setfattr -n user.storm.migrated -v "1" $TEST_DIRECTORY/tapeonly.txt

echo "test nearline file recalled" > $TEST_DIRECTORY/recallinprogress.txt
setfattr -n user.storm.online -v "False" $TEST_DIRECTORY/recallinprogress.txt
setfattr -n user.storm.migrated -v "1" $TEST_DIRECTORY/recallinprogress.txt
setfattr -n user.TSMRecD -v "1495721014482" $TEST_DIRECTORY/recallinprogress.txt
setfattr -n user.TSMRecR -v "0" $TEST_DIRECTORY/recallinprogress.txt
setfattr -n user.TSMRecT -v "5b44eee4-de80-4d9c-b4ac-d4a205b4a9d4" $TEST_DIRECTORY/recallinprogress.txt

chown storm:storm $TEST_DIRECTORY/diskonly.txt $TEST_DIRECTORY/diskandtape.txt $TEST_DIRECTORY/tapeonly.txt $TEST_DIRECTORY/recallinprogress.txt
chmod 750 $TEST_DIRECTORY/diskonly.txt $TEST_DIRECTORY/diskandtape.txt $TEST_DIRECTORY/tapeonly.txt $TEST_DIRECTORY/recallinprogress.txt

popd