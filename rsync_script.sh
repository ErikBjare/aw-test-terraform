#!/bin/bash

# Add the IPs of the other containers here, separated by spaces
REMOTE_IPS="$1"

SRC_DIR="/home/desktopuser/ActivityWatchSync/"
KEY_PATH="/home/desktopuser/.ssh/id_ed25519"

for ip in ${REMOTE_IPS}; do
    rsync -avz -e "ssh -i ${KEY_PATH}" --exclude '.sync/' --exclude '.DS_Store' ${SRC_DIR} desktopuser@${ip}:${SRC_DIR}
done
