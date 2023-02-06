#!/usr/bin/env bash

# REQ: Installs and configures fail2ban on Ubuntu Server. <skr 2023-02-05>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -x xtrace

script_dir="$(basename "$0")"

source_path="$script_dir/../config/jail.local"

jail_path='/etc/fail2ban/jail.local'

sudo apt-get update
sudo apt-get install --yes -- fail2ban

sudo install \
  --owner='root' \
  --group='root' \
  --mode=644 \
-- <(echo "$jail_content") "$jail_path"

sudo systemctl restart fail2ban
