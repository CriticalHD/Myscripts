#!/bin/bash
# =============================================
# VT2 Script: Robust Install libpci
# =============================================

# Exit on error only for critical steps, but allow optional checks
set -e

# Helper: install a package if missing
install_if_missing() {
  local cmd=$1
  local pkg=$2
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found, installing $pkg via Chromebrew..."
    crew install "$pkg"
  else
    echo "$cmd found."
  fi
}

echo "Step 1: Ensure build tools are installed..."
install_if_missing gcc gcc
install_if_missing g++ g++
install_if_missing make make
install_if_missing pkg-config pkg-config

echo "Step 2: Download pciutils source..."
curl -sSL -o /tmp/pciutils.tar.gz https://mj.ucw.cz/sw/pciutils/pciutils-3.14.tar.gz

echo "Step 3: Extract pciutils..."
cd /tmp
tar -xzf pciutils.tar.gz
cd pciutils-3.14

echo "Step 4: Set compiler and linker paths..."
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

echo "Step 5: Configure, compile, and install libpci..."
./configure --prefix=/usr/local
make
sudo make install

echo "======================================"
echo "libpci has been installed!"
echo "Headers: /usr/local/include/pci"
echo "Libraries: /usr/local/lib/libpci.*"
echo "Your VT2 environment is now ready to compile projects requiring libpci."
echo "======================================"
