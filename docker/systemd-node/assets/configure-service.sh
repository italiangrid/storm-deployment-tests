#!/bin/bash

# Install StoRM services
puppet apply --detailed-exitcodes /assets/manifest.pp

# check if errors occurred after puppet apply:
if [[ ( $? -eq 4 ) || ( $? -eq 6 ) ]]; then
  exit 1
fi