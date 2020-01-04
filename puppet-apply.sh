#!/bin/sh -euo pipefail

REPOSITORY_ROOT=/var/lib/coderdojo-deploy

cd "${REPOSITORY_ROOT}"
git pull
git submodule init
git submodule update --remote --merge
puppet apply "${REPOSITORY_ROOT}/manifests/site.pp"
