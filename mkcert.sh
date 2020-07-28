#!/bin/sh

if [ -z $1 ]; then
    hostname=localhost
else
    hostname=$1
fi

cat > 'openssl.conf' <<EOF
[ req ]
default_bits = 2048
encrypt_key = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
EOF

openssl req -x509 -new -config './openssl.conf' -subj "/CN=$hostname/" \
            -out "$hostname.crt"  -keyout "$hostname.key"


