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
  cd "${REPOSITORY_ROOT}"
  set -x
  git remote update origin
  git reset --hard origin/master
  git restore .
  librarian-puppet install --verbose ||
    librarian-puppet install --verbose --clean
}

function updateSecrets() {
  if [[ -d /root/secrets/ ]]; then
    cd /root/secrets/
    set -x
    git remote update origin
    git reset --hard origin/master
    git restore .
  fi
}

function applyPuppet() {
  export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

  puppet apply --confdir="${REPOSITORY_ROOT}" "${REPOSITORY_ROOT}/manifests/site.pp" "$@"
}

if ps aux | grep -v grep | grep -q "/opt/puppetlabs/puppet/bin/puppet"; then
  echo "Puppet is already running!"
  exit 1
fi

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
  if checkNetwork; then
    updatePuppet
    updateSecrets
  fi
fi

applyPuppet "$@"
