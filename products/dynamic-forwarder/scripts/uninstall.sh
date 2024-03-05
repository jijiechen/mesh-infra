#!/bin/bash

crontab -l 2>/dev/null | grep -v refresh-sni-proxy | crontab -

systemctl stop envoy.service
systemctl disable envoy.service
rm -f /etc/systemd/system/envoy.service
systemctl daemon-reload