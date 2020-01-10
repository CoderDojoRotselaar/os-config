#!/bin/bash

set -eu
set -o pipefail

source /etc/os-release
REPOSITORY_ROOT=/var/lib/puppet-deployment

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
  if ! command -v puppet >/dev/null; then
    echo "Puppet not yet installed - installing now..."
    if !rpm -q puppet-release; then
      yum -y install https://yum.puppetlabs.com/puppet-release-fedora-30.noarch.rpm
    fi
    yum -y install puppet-agent git-core
  fi
  GEM_INSTALL_PARAMS=""
  ;;
Ubuntu)
  if ! command -v puppet >/dev/null; then
    echo "Puppet not yet installed - installing now..."
    if !dpkg -l puppet-release; then
      . /etc/lsb-release
      curl -sSL https://apt.puppetlabs.com/puppet-release-${DISTRIB_CODENAME}.deb >/tmp/puppet-release.deb
      dpkg -i /tmp/puppet-release.deb
      rm -f /tmp/puppet-release.deb
    fi
    apt update
    apt -y install puppet-agent git-core
  fi
  GEM_INSTALL_PARAMS="--no-ri --no-rdoc"
  ;;
*)
  echo "Unknown/unsupported operating system. Bailing out." >&2
  exit 1
  ;;
esac

if ! command -v librarian-puppet >/dev/null; then
  echo "Librarian-puppet not yet installed - installing now..."
  gem install $GEM_INSTALL_PARAMS librarian-puppet
fi

if [[ ! -d "${REPOSITORY_ROOT}" ]]; then
  git clone --depth 1 https://github.com/CoderDojoRotselaar/os-config "${REPOSITORY_ROOT}"
fi

${REPOSITORY_ROOT}/puppet-apply.sh
