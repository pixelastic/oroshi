#!/usr/bin/env zsh
set -e

local iconDir=/usr/share/icons/hicolor/scalable/apps
cd $iconDir
sudo rm \
  redshift-status-off.svg \
  redshift-status-on.svg \
  redshift-status.svg \

sudo cp ~/.oroshi/config/ubuntu/20.04/redshift/redshift.svg .
sudo cp ./redshift.svg ./redshift-status-off.svg
sudo cp ./redshift.svg ./redshift-status-on.svg
