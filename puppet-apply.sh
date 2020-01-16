#!/bin/bash

. /etc/profile.d/puppet-agent.sh

set -eu

function checkNetwork() {
  if ! ping -q -W 1 -i 1 -c 1 github.com; then
    echo "No internet or github.com unreachable."
    return 1
  fi
  echo "I could reach repo.icts.kuleuven.be -- all is well!"
}

function updatePuppet() {
  if checkNetwork; then
    cd "${REPOSITORY_ROOT}"
    set -x
    git reset --hard HEAD
    git pull origin master
    librarian-puppet install --verbose ||
      librarian-puppet install --verbose --clean
  fi
}

function applyPuppet() {
  puppet apply --confdir="${REPOSITORY_ROOT}" "${REPOSITORY_ROOT}/manifests/site.pp" "$@"
}

cmd="update"
if [[ -n "${1:-}" ]]; then
  case "$1" in
  -*)
    # nothing
    ;;
  *)
    cmd="$1"
    shift
    ;;
  esac
fi

REPOSITORY_ROOT=/var/lib/puppet-deployment

if [[ "${cmd}" == "update" ]]; then
  updatePuppet
fi

applyPuppet "$@"
