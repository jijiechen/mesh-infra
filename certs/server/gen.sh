#!/bin/bash

set -e 

WILDCARD_BASE_DOMAIN=$1
if [ -z "$WILDCARD_BASE_DOMAIN" ]; then
    echo "Please specify the base domain for the wildcard domain as argument 1."
    exit 1
fi

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TMP_DIR=/tmp/$RANDOM
mkdir $TMP_DIR

cp $SCRIPTPATH/../ca/ca.key $TMP_DIR/ca.key
cp $SCRIPTPATH/../ca/ca.pem $TMP_DIR/ca.pem
cp $SCRIPTPATH/../ca/openssl.cnf $TMP_DIR/openssl.cnf
echo "DNS.1 = $WILDCARD_BASE_DOMAIN" >> $TMP_DIR/openssl.cnf
echo "DNS.2 = *.$WILDCARD_BASE_DOMAIN" >> $TMP_DIR/openssl.cnf

openssl genrsa -out $TMP_DIR/server.key 2048
openssl req -new -key $TMP_DIR/server.key -out $TMP_DIR/server.csr -subj "/C=CN/ST=Beijing/L=Chaoyang/O=DevOps/OU=PKI/CN=$WILDCARD_BASE_DOMAIN"
openssl x509 -req -extensions v3_req -sha256 -days 365 \
    -CA $TMP_DIR/ca.pem -CAkey $TMP_DIR/ca.key -CAcreateserial -extfile $TMP_DIR/openssl.cnf \
    -in $TMP_DIR/server.csr -out $TMP_DIR/server.pem

cp $TMP_DIR/ca.pem ./
cp $TMP_DIR/server.key ./
cp $TMP_DIR/server.pem ./
rm -rf $TMP_DIR