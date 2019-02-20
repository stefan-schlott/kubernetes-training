#!/bin/bash

NAME=$1
TMP_FOLDER=${2:-tmp/tls}

cd ${TMP_FOLDER}

# generate CSR
# generate key
openssl genrsa -out ${NAME}/${NAME}.key

# generate CSR
openssl req -new -key ${NAME}/${NAME}.key -out ${NAME}/${NAME}.csr -config ${NAME}/${NAME}.csr.conf

# sign CSR (with CA)
openssl x509 -req -in ${NAME}/${NAME}.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${NAME}/${NAME}.crt -days 365 -extensions v3_ext -extfile ${NAME}/${NAME}.csr.conf
