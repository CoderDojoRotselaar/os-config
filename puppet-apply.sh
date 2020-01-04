#!/bin/bash -eu

if ! ping -c 1 github.com -q; then
	echo "No internet or github.com unreachable. Bailing out now."
	exit 1
fi

REPOSITORY_ROOT=/var/lib/coderdojo-deploy

cd "${REPOSITORY_ROOT}"
git pull
git submodule init
git submodule update --remote --merge
puppet apply "${REPOSITORY_ROOT}/manifests/site.pp"
