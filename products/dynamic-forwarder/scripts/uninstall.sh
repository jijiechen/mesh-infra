#!/bin/bash

systemctl stop envoy.service
systemctl disable envoy.service
rm -f /etc/systemd/system/envoy.service
systemctl daemon-reload
