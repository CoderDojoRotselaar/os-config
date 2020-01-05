#!/bin/bash
set -eu

function checkNetwork() {
	if ! ping -q -W 1 -i 1 -c 1 github.com; then
		echo "No internet or github.com unreachable. Bailing out now."
		exit 1
	fi
}

function updatePuppet() {
	set -x
	git pull
	librarian-puppet update --verbose
}

cmd=${1:-update}
shift
REPOSITORY_ROOT=/var/lib/coderdojo-deploy

cd "${REPOSITORY_ROOT}"

case "${cmd}" in
update)
	checkNetwork
	updatePuppet
	;;
esac

set -x
puppet apply "${REPOSITORY_ROOT}/manifests/site.pp"
