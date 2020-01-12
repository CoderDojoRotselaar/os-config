#!/bin/bash

curl -sSL https://raw.githubusercontent.com/CoderDojoRotselaar/os-config/master/bootstrap/deploy.sh \
  >/usr/local/sbin/deploy.sh
chmod a+x /usr/local/sbin/deploy.sh

cat <<EOF >/etc/systemd/system/auto-deploy.service
[Unit]
Description=yourscript
ConditionPathExists=/.deploy

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/deploy.sh
ExecStartPost=/bin/rmdir /.deploy

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable auto-deploy
mkdir /.deploy
