#!/bin/bash
set -e

docker build --pull=false --rm=true -t italiangrid/storm-node .