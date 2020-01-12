#!/bin/bash

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
