#!/bin/bash
set -eu

function checkNetwork() {
	if ! ping -q -W 1 -i 1 -c 1 github.com; then
		echo "No internet or github.com unreachable. Bailing out now."
		exit 1
	fi
}

function updatePuppet() {
	cd "${REPOSITORY_ROOT}"
	set -x
	git pull
	librarian-puppet update --verbose
}

function applyPuppet() {
	cd "${REPOSITORY_ROOT}"
	set -x
	puppet apply "${REPOSITORY_ROOT}/manifests/site.pp"
}

cmd=${1:-update}
REPOSITORY_ROOT=/var/lib/coderdojo-deploy

case "${cmd}" in
update)
	checkNetwork
	updatePuppet
	applyPuppet
	;;
apply)
	applyPuppet
	;;
*)
	echo "Unknown command. Bailing out now."
	exit 1
	;;
esac
