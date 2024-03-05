#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ulimit -n 102400
sysctl fs.inotify.max_user_watches=524288
sysctl -p

# install envoy (requires CentOS/Rocky)
curl -1sLf \
  'https://rpm.dl.getenvoy.io/public/setup.rpm.sh' \
  | sudo -E bash

yum install getenvoy-envoy

# install envoy as a service
BASE_DIR=$(cd $SCRIPT_DIR/..; pwd)
sed "s;PWD;$BASE_DIR;g" $BASE_DIR/envoy/envoy.service > /etc/systemd/system/envoy.service

systemctl daemon-reload
systemctl enable envoy.service
systemctl start envoy.service


echo "================"
echo "Installation complete."