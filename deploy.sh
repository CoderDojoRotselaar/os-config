#!/bin/sh -euo pipefail

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

set -x
case "$NAME" in
Fedora)
	yum -y install puppet git-core
	;;
Ubuntu | Endless)
	apt update
	apt -y install puppet git-core
	;;
*)
	echo "Unknown/unsupported operating system. Bailing out." >&2
	exit 1
	;;
esac

puppet config set codedir "${REPOSITORY_ROOT}"

if [[ ! -d "${REPOSITORY_ROOT}" ]]; then
	git clone https://github.com/CoderDojoRotselaar/os-config "${REPOSITORY_ROOT}"
fi

if [[ ! -e /usr/sbin/puppet-apply ]]; then
	ln -s "${REPOSITORY_ROOT}/puppet-apply.sh" /usr/sbin/puppet-apply
fi

/usr/sbin/puppet-apply
