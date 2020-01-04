#!/bin/bash -eu

if ! ping -q -W 1 -i 1 -c 1 github.com; then
	echo "No internet or github.com unreachable. Bailing out now."
	exit 1
fi

REPOSITORY_ROOT=/var/lib/coderdojo-deploy

cd "${REPOSITORY_ROOT}"
git pull
git submodule init
git submodule update --remote --merge
puppet apply "${REPOSITORY_ROOT}/manifests/site.pp"
