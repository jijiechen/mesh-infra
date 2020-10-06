#!/bin/bash

# Generate CA:
    # openssl genrsa -out ./ca-key.pem 4096
    # openssl req -new -x509 -nodes -sha256 -key ca-key.pem -out ca-cert.pem

# Generate Certificate:
    # edit openssl.cnf
    # openssl genrsa -out server.key 2048
    # openssl req -new -key server.key -out server.csr
    # openssl x509 -req -extensions v3_req -days 3649 -sha256 -CA  ca-cert.pem -CAkey ca-key.key -CAcreateserial -in server.csr -out server.pem -extfile ./openssl.cnf

# kubectl create secret tls addon-certificates --key server.key --cert server.pem
