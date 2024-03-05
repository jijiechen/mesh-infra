#!/bin/bash


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
docker run -p 8443:443 -v $SCRIPT_DIR/../:/etc/forwarder -w /etc/forwarder envoyproxy/envoy:v1.18.6 -c /etc/forwarder/envoy/envoy.yaml