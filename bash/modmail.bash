#!/usr/bin/env bash

# REQ: Installs modmail as a systemd service. <skr 2023-02-05>

# SEE: https://github.com/transprogrammer/modmail#local-hosting-general-guide <>

# TODO: Template modmail service file. <>

# !!!: Template env file <SKR>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -x xtrace

org='transprogrammer'
name='modmail'

script_dir="$(dirname "$0")"

declare -A repository=(
  ['dir']="/usr/local/src/$name"
  ['url']="https://github.com/$org/$name.git"
)
repository['requirements']="${repository['dir']}/requirements.txt"

declare -A unit=(
  ['source']="$script_dir/../config/$name.service"
  ['target']="/etc/systemd/system/$name.service"
  ['owner']='root'
  ['group']='root'
  ['mode']='644'
)
unit['name']="$(basename "${unit[target_path]}" .service)"

sudo rm -rf "${repository['dir']}/requirements.txt"
git clone "${repository['url']}" "${repository['dir']}"
pip install --requirment "${repository['dir']}/requirements.txt"

sudo install \
  --owner="${unit['owner']}" \
  --group="${unit['group']}" \
   --mode="${unit['mode']}"  \
-- "${unit['source']}" "${unit['target']}"

sudo systemctl daemon-reload
sudo systemctl start  "${unit[name]}" 
sudo systemctl enable "${unit[name]}"
sudo systemctl status "${unit[name]}"
