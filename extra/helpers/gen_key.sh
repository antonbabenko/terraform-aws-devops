#!/bin/bash
set -e

usage() {
  cat <<EOF
Generate a SSL keys

Usage:

  $0 <KEY_PATH> **<EXISTING_KEY>**

Where KEY_PATH is the path to the directory these keys will be placed, in relation to the directory this script is in.

There is an optional second argument you can include that uses an existing private key.

This will generate a .pem private key and a .pub public key in the directory specified.
EOF

  exit 1
}

KEYPATH=$1

if [ "x$KEYPATH" == "x" ]; then
  echo
  echo "ERROR: Specify key path as the first argument, e.g. ../infrastructures/terraform/keys"
  echo
  usage
fi

EXISTINGKEY=$2
KEY="$KEYPATH/example"

if [ -s "$KEY.pem" ] && [ -s "$KEY.pub" ] && [ -z "$EXISTINGKEY" ]; then
  echo Using existing key pair
else
  rm -rf $KEY*
  mkdir -p $KEYPATH

  if [ -z "$EXISTINGKEY" ]; then
    echo No key pair exists and no private key arg was passed, generating new keys...
    openssl genrsa -out $KEY.pem 1024
    chmod 400 $KEY.pem
    ssh-keygen -y -f $KEY.pem > $KEY.pub
  else
    echo Using private key $EXISTINGKEY for key pair...
    cp $EXISTINGKEY $KEY.pem
    chmod 400 $KEY.pem
    ssh-keygen -y -f $KEY.pem > $KEY.pub
  fi

  ssh-add $KEY.pem
fi
