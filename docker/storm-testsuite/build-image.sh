#!/bin/bash
set -ex

docker build --pull=false --rm=true --no-cache=true -t italiangrid/storm-testsuite .
