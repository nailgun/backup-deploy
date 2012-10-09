#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo 'USAGE: install_key.sh USERNAME KEYFILE' >&2
    exit 1
fi

need_user=$1
need_uid=$(id -u "$need_user")
keyfile=$2

if [ $EUID -ne $need_uid ]; then
    echo "Enter $USER password on backup server now"
    exec sudo -u "$need_user" "${BASH_SOURCE[0]}" $@
fi

umask 077
home=$(eval echo ~${need_user})
mkdir -p $home/.ssh
cat $keyfile >> $home/.ssh/authorized_keys
