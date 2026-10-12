#!/bin/bash

set -e

echo "Installing prerequisites..."
# Only installs what's missing; falls back to conda-forge if there's no sudo.
bash <(curl -fsSL "https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared/install-prereqs.sh") \
    unzip curl git -- fontconfig libatomic1
