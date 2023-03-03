#!/usr/bin/env bash

set +B -Cefuxo pipefail

# Executes the dotnet project. <skr 2023-02-02>

dir=$(dirname "../$0")

dotnet build
dotnet run --no-build
