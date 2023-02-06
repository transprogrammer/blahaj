#!/usr/bin/env bash

# REQ: Installs modmail as a systemd service. <skr 2023-02-05>

# SEE: https://github.com/transprogrammer/modmail#local-hosting-general-guide <>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -x xtrace

service_name='modmail'

script_dir="$(dirname "$0")"

declare -A unit_paths=(
  ['source']="$script_dir/../config/$service_name.service"
  ['target']="/etc/systemd/system/$service_name.service"
)

sudo install --owner='root' --group='root' --mode='644' \
-- "${unit_paths['source']}" "${unit_paths['target']}"

sudo systemctl daemon-reload

sudo systemctl start  "$service_name" 
sudo systemctl enable "$service_name"

sudo systemctl status "$service_name"
