#!/bin/bash
adduser --disabled-password --disabled-login --gecos "" mastodon
adduser --disabled-password --disabled-login --gecos "" postgre
whoami
sudo -u mastodon bash << EOF
echo "In"
whoami
EOF
echo "Out"
whoami
sudo -u postgre bash << EOF
echo "In"
whoami
EOF
echo "Out"
whoami
