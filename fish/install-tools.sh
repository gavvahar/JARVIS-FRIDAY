#!/bin/bash

set -e

BASE="https://raw.githubusercontent.com/gavvahar/JARVIS-FRIDAY/main/shared"
bash <(curl -fsSL "$BASE/install-tools.sh") --bin
