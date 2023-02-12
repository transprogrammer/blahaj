#!/usr/bin/env bash

# REQ: Install project prerequisites. <skr 2022-07>

# SEE: https://github.com/python/devguide/blob/main/getting-started/setup-building.rst#linux <>

# NOBUG: https://github.com/aio-libs/aiohttp/issues/6600 <2022-07-27>
export AIOHTTP_NO_EXTENSIONS=1
PYTHON_VERSION='v3.10.5'

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail

[[ -n ${TRACE+is_set} ]] || set -o xtrace

function make_entry {
  local -r archive_type='deb-src' 
  local -r repository_url='http://deb.debian.org/debian'
  local -r distribution='testing'
  local -r component='main'

  declare -Ag entry
  entry[line]="$archive_type"
  entry[line]+=" $repository_url"
  entry[line]+=" $distribution"
  entry[line]+=" $component"
  readonly entry
}
make_entry

readonly -A sources=(
  [file]='/etc/apt/sources.list'
  [build-dep]='python3'
)

readonly -A repo=(
  [url]='https://github.com/python/cpython.git'
)

readonly packages=(
  'pkg-config'
  'build-essential'
  'gdb'
  'git'
  'lcov'
  'pkg-config'
  'libbz2-dev'
  'libffi-dev'
  'libgdbm-dev'
  'libgdbm-compat-dev'
  'liblzma-dev'
  'libncurses5-dev'
  'libreadline6-dev'
  'libsqlite3-dev'
  'libssl-dev'
  'lzma'
  'lzma-dev'
  'tk-dev'
  'uuid-dev'
  'zlib1g-dev'
)

readonly edge_packages=(
 'libb2-dev'
)

function main {
  if ! grep -qxF "${entry[line]}" "${sources[file]}"
  then
    echo "${entry[line]}" >> "${sources[file]}"
  fi

  apt-get update
  apt-get build-dep -y "${sources[build-dep]}"
  apt-get install -y "${packages[@]}" "${edge_packages}" 

  cd /tmp
  rm -rf $(basename "${repo[url]}" .git)
  git clone -b "$PYTHON_VERSION" "${repo[url]}" "$_"
  cd "$_"
  ./configure --with-pydebug
  make -s -j2
  # make test
  make install
}

main

