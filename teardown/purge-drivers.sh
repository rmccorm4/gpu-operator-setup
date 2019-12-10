#!/bin/bash

# Enforce running as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "[ERROR] This script must be run with sudo." >&2
    exit 1
fi

# Remove nvidia drivers
apt purge nvidia*
