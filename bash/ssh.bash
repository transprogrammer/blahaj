#!/usr/bin/env bash

# NOTE: ssh's into the modmail server. <skr 2023-02-05>

# TODO: Query bicep/azure for machine details. <>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail
set -x xtrace

keyfile=~/'src/blahaj/ssh/id_rsa'

username='uwu'

hostname='blahaj.eastus2.cloudapp.azure.com'

ssh -i "$keyfile" -- "$username@$hostname"
echo ssh -i "$keyfile" -- "$username@$hostname"
