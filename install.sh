#!/bin/bash

SSH_HOST=nailgun@backup.nailgun.name

set -e

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function mkpw() {
    if which uuencode &> /dev/null; then
        encode="uuencode -m -"
    else
        encode="base64"
    fi
    head /dev/urandom | $encode | sed -n 2p | cut -c1-${1:-15}
}

if [ $# -ne 1 ]; then
    echo 'USAGE: install.sh HOSTNAME' >&2
    exit 1
fi
myhost=$1

if [ -e ~/.ssh/id_rsa.pub ]; then
    echo '-----[ SSH key already exist, skip generation ...'
else
    echo '-----[ Generating SSH key ...'
    ssh-keygen -N '' -f ~/.ssh/id_rsa
fi

echo '-----[ Installing SSH key to backup host ...'
scp ~/.ssh/id_rsa.pub $SSH_HOST:/tmp/new_key
ssh -t $SSH_HOST /backup/install_key.sh $myhost /tmp/new_key

if which mysql &> /dev/null; then
    umask 077

    echo '-----[ Creating mysql user ...'
    echo 'Enter mysql root password now'
    MYSQL_PWD=$(mkpw)

    mysql -u root -p << EOF
GRANT SELECT ON *.* TO backup@localhost IDENTIFIED BY "$MYSQL_PWD";
GRANT LOCK TABLES ON *.* TO backup@localhost IDENTIFIED BY "$MYSQL_PWD";
GRANT RELOAD ON *.* TO backup@localhost IDENTIFIED BY "$MYSQL_PWD";
EOF

    cat > $HERE/.my.cnf << EOF
[client]
user=backup
password=$MYSQL_PWD
EOF

fi
