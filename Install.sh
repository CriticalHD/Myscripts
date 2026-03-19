#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 3.1
# =============================================

VERSION="3.1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "$BLUE======================================$NC"
echo -e "$BLUE libpci Installer (VT2) $NC"
echo -e "$BLUE Version: $VERSION $NC"
echo -e "$BLUE======================================$NC"

# -------------------------------
# Build directory (safe)
# -------------------------------
BUILD_DIR="$HOME/build_libpci"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# -------------------------------
# Tools
# -------------------------------
echo -e "$BLUE Checking tools... $NC"

for pkg in gcc make tar xz curl; do
    if ! command -v $pkg >/dev/null 2>&1; then
        echo -e "$YELLOW Installing $pkg... $NC"
        crew install -y $pkg
    else
        echo -e "$GREEN $pkg OK $NC"
    fi
done

# -------------------------------
# Download
# -------------------------------
echo -e "$BLUE Downloading pciutils... $NC"

URL="https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.14.0.tar.xz"

curl -L -o pciutils.tar.xz "$URL"

if [ ! -f pciutils.tar.xz ]; then
    echo -e "$RED Download failed $NC"
    exit 1
fi

# -------------------------------
# Extract
# -------------------------------
echo -e "$BLUE Extracting... $NC"

tar -xJf pciutils.tar.xz
cd pciutils-3.14.0 || exit 1

# -------------------------------
# CRITICAL FIXES
# -------------------------------

echo -e "$BLUE Fixing permissions... $NC"
chmod -R 755 .

echo -e "$BLUE Forcing executable scripts... $NC"
find . -type f -name "*.sh" -exec chmod +x {} \;

# Disable problematic features
echo -e "$BLUE Adjusting config (VT2 fix)... $NC"
sed -i 's/HAVE_ZLIB=yes/HAVE_ZLIB=no/' lib/config.mk 2>/dev/null

# -------------------------------
# Build (FORCED SAFE MODE)
# -------------------------------
echo -e "$BLUE Building libpci... $NC"

make PREFIX=/usr/local CC=gcc HOSTCC=gcc ZLIB=no

if [ $? -ne 0 ]; then
    echo -e "$RED Build failed (still blocked by VT2)$NC"
    exit 1
fi

echo -e "$GREEN Build OK $NC"

# -------------------------------
# Install
# -------------------------------
echo -e "$BLUE Installing... $NC"

sudo make PREFIX=/usr/local install

if [ $? -ne 0 ]; then
    echo -e "$RED Install failed $NC"
    exit 1
fi

# -------------------------------
# Done
# -------------------------------
echo -e "$BLUE======================================$NC"
echo -e "$GREEN libpci installed successfully! $NC"
echo -e "$GREEN /usr/local/include/pci $NC"
echo -e "$GREEN /usr/local/lib/libpci.* $NC"
echo -e "$BLUE======================================$NC"
