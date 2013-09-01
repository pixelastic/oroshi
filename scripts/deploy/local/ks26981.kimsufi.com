#!/usr/bin/env zsh
# Hostname: ks26981.kimsufi.com
# Description: Headless kimsufi server

cd ~/.oroshi/scripts/deploy/

# Config files
./ack
./dircolors
./git
./hg
./hosts
./ssh
./tidy
./vim
./zsh
