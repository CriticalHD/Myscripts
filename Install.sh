#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 2.2 (Syntax-safe)
# =============================================

# Colors (safe)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "$BLUE======================================$NC"
echo -e "$BLUE VT2 libpci Installer (v2.2) $NC"
echo -e "$BLUE======================================$NC"

# -------------------------------
# Install required tools
# -------------------------------
echo -e "$BLUE Checking tools... $NC"

if ! command -v gcc >/dev/null 2>&1; then
    echo -e "$YELLOW Installing gcc... $NC"
    crew install -y gcc
fi

if ! command -v make >/dev/null 2>&1; then
    echo -e "$YELLOW Installing make... $NC"
    crew install -y make
fi

if ! command -v tar >/dev/null 2>&1; then
    echo -e "$YELLOW Installing tar... $NC"
    crew install -y tar
fi

if ! command -v xz >/dev/null 2>&1; then
    echo -e "$YELLOW Installing xz... $NC"
    crew install -y xz
fi

if ! command -v curl >/dev/null 2>&1; then
    echo -e "$YELLOW Installing curl... $NC"
    crew install -y curl
fi

# -------------------------------
# Download pciutils
# -------------------------------
echo -e "$BLUE Downloading pciutils... $NC"

URL="https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.14.0.tar.xz"

curl -L -o /tmp/pciutils.tar.xz "$URL"

if [ ! -f /tmp/pciutils.tar.xz ]; then
    echo -e "$RED Download failed $NC"
    exit 1
fi

echo -e "$GREEN Download OK $NC"

# -------------------------------
# Extract
# -------------------------------
echo -e "$BLUE Extracting... $NC"

cd /tmp
tar -xJf pciutils.tar.xz

if [ ! -d pciutils-3.14.0 ]; then
    echo -e "$RED Extraction failed $NC"
    exit 1
fi

cd pciutils-3.14.0

# -------------------------------
# Fix permissions
# -------------------------------
chmod -R +x .

# -------------------------------
# Build
# -------------------------------
echo -e "$BLUE Building libpci... $NC"

make PREFIX=/usr/local

if [ $? -ne 0 ]; then
    echo -e "$RED Build failed $NC"
    exit 1
fi

echo -e "$GREEN Build OK $NC"

# -------------------------------
# Install (sudo required)
# -------------------------------
echo -e "$BLUE Installing... $NC"

sudo make PREFIX=/usr/local install

if [ $? -ne 0 ]; then
    echo -e "$RED Install failed $NC"
    exit 1
fi

echo -e "$GREEN Install OK $NC"

# -------------------------------
# Done
# -------------------------------
echo -e "$BLUE======================================$NC"
echo -e "$GREEN libpci installed successfully! $NC"
echo -e "$GREEN /usr/local/include/pci $NC"
echo -e "$GREEN /usr/local/lib/libpci.* $NC"
echo -e "$BLUE======================================$NC"
