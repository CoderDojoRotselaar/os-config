#!/bin/sh -eu

source /etc/os-release

cat << EOF
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

if [[ "$USER" != "root" ]]
then
  cat << EOF
This script requires superuser access. You should rerun it as:
$ sudo $0 ${@@Q}
EOF
exit 1
fi

set -x
case "$NAME" in
  Fedora)
    yum -y install puppet
    ;;
  Ubuntu)
    apt update
    apt -y install puppet
    ;;
  *)
    echo "Unknown/unsupported operating system. Bailing out." >&2
    exit 1
    ;;
esac
