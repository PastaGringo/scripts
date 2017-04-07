#!/bin/bash
whoami
sudo -u someuser bash << EOF
echo "In"
whoami
EOF
echo "Out"
whoami
