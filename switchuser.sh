#!/bin/bash
adduser --disabled-password --disabled-login mastodon
adduser --disabled-password --disabled-login postgre
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
