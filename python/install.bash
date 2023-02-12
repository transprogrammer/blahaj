#!/usr/bin/env bash

# REQ: Installs launch prerequisites. <skr 2022-07>

set -o braceexpand
set -o errexit
set -o noclobber
set -o nounset
set -o noglob
set -o pipefail

readonly BREW_URL='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'

brew --version || bash -c "$(curl -fsSL "$BREW_URL")"

brew bundle

