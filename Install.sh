#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 1.0
# =============================================

set -e  # exit on critical failures

SCRIPT_VERSION="1.0"

echo "======================================"
echo "VT2 libpci Installer"
echo "Script Version: $SCRIPT_VERSION"
echo "======================================"

# -------------------------------
# Helper: install package if missing
# -------------------------------
install_if_missing() {
    local cmd=$1
    local pkg=$2
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd not found. Installing $pkg via Chromebrew..."
        crew install "$pkg"
    else
        echo "$cmd is already installed."
    fi
}

echo "Step 1: Ensure build tools are installed..."
install_if_missing gcc gcc
install_if_missing g++ g++
install_if_missing make make
install_if_missing pkg-config pkg-config

echo "Step 2: Download pciutils (for libpci)..."
PCIUTILS_URL="https://mj.ucw.cz/sw/pciutils/pciutils-3.14.tar.gz"
curl -sSL -o /tmp/pciutils.tar.gz "$PCIUTILS_URL"

# Verify download roughly
if [ ! -s /tmp/pciutils.tar.gz ]; then
    echo "ERROR: pciutils download failed or file is empty."
    exit 1
fi

echo "Step 3: Extract pciutils..."
cd /tmp
tar -xzf pciutils.tar.gz
cd pciutils-3.14

echo "Step 4: Set compiler/linker paths..."
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

echo "Step 5: Configure, compile, and install libpci..."
./configure --prefix=/usr/local
make
sudo make install

echo "======================================"
echo "libpci installed successfully!"
echo "Headers: /usr/local/include/pci"
echo "Libraries: /usr/local/lib/libpci.*"
echo "You can now run make for projects that need libpci."
echo "Script version: $SCRIPT_VERSION"
echo "======================================"
