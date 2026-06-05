#!/bin/bash

set -e

echo "Installing prerequisites..."
sudo apt update
sudo apt install -y unzip curl git fontconfig libatomic1
echo "✅ Prerequisites installed"
