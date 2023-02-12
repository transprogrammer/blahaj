#!/usr/bin/env bash

# REQ: Runs the python script. <skr 2023-02-11>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -o xtrace 

script_dir=$(dirname "$0")

pip install -r "$script_dir/requirements.txt"

"$script_dir/main.py"
