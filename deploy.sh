#!/bin/bash

set -eu
set -o pipefail

source /etc/os-release
REPOSITORY_ROOT=/var/lib/coderdojo-deploy

cat <<EOF
This script will update this system to a CoderDojo laptop as used in Rotselaar.
If you are running this script by accident, you should exit now (type ctrl+c).

Detected OS: '$NAME'

This script will:
* install puppet
* checkout the Puppet manifests found on Github
* apply that configuration to this system
* periodically update the git repository and apply

Press enter to continue the deployment.
Press ctrl+c to abort now.
EOF
read

if [[ "$USER" != "root" ]]; then
  cat <<EOF
This script requires superuser access. You should rerun it as:
$ sudo $0 ${@@Q}
EOF
  exit 1
fi

case "$NAME" in
Fedora)
  INSTALL_PRE_COMMAND="yum -y clean all"
  INSTALL_COMMAND=yum
  INSTALL_PRE_PARAMS="-y install"
  GEM_INSTALL_PARAMS=""
  ;;
Ubuntu)
  INSTALL_PRE_COMMAND="apt update"
  INSTALL_COMMAND=apt
  INSTALL_PRE_PARAMS="-y install"
  GEM_INSTALL_PARAMS="--no-ri --no-rdoc"
  ;;
*)
  echo "Unknown/unsupported operating system. Bailing out." >&2
  exit 1
  ;;
esac

set -x

if ! command -v puppet >/dev/null; then
  echo "Puppet not yet installed - installing now..."
  $INSTALL_PRE_COMMAND
  $INSTALL_COMMAND $INSTALL_PRE_PARAMS puppet git-core
fi

if ! command -v librarian-puppet >/dev/null; then
  echo "Librarian-puppet not yet installed - installing now..."
  gem install $GEM_INSTALL_PARAMS librarian-puppet
fi

if [[ ! -d "${REPOSITORY_ROOT}" ]]; then
  git clone --depth 1 https://github.com/CoderDojoRotselaar/os-config "${REPOSITORY_ROOT}"
fi

${REPOSITORY_ROOT}/puppet-apply.sh
