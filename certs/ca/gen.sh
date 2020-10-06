#!/bin/bash

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=CN/ST=Beijing/L=Chaoyang/O=DevOps/OU=PKI/CN=DevOps Generic Root" \
    -keyout ca.key  -out ca.pem