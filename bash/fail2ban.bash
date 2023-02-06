#!/usr/bin/env bash

# REQ: Installs and configures fail2ban on Ubuntu Server. <skr 2023-02-05>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -x xtrace

script_dir="$(dirname "$0")"

declare -A jail_paths=(
  ['source']="$script_dir/../config/jail.local"
  ['target']='/etc/fail2ban/jail.local'
)

sudo apt-get update
sudo apt-get install --yes -- fail2ban

sudo install \
  --owner='root' \
  --group='root' \
  --mode=644 \
-- "${jail_paths['source']}" "${jail_paths['target']}"

sudo systemctl restart fail2ban

sudo fail2ban-client status
