#!/bin/bash
# =============================================
# VT2 Script to install libpci (pciutils)
# =============================================

set -e  # Exit on any error

# Step 1: Install minimal build tools via Chromebrew
echo "Installing compiler and build tools..."
crew install gcc g++ make binutils pkg-config

# Step 2: Download pciutils source
echo "Downloading pciutils source..."
curl -L -o /tmp/pciutils.tar.gz https://mj.ucw.cz/sw/pciutils/pciutils-3.14.tar.gz

# Step 3: Extract source
echo "Extracting pciutils..."
cd /tmp
tar -xzf pciutils.tar.gz
cd pciutils-3.14

# Step 4: Set compiler and linker paths
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

# Step 5: Configure, compile, and install
echo "Configuring, building, and installing libpci..."
./configure --prefix=/usr/local
make
sudo make install

echo "======================================"
echo "libpci has been installed to /usr/local"
echo "Headers: /usr/local/include/pci"
echo "Libraries: /usr/local/lib/libpci.*"
echo "You can now run make for projects that need libpci."
echo "======================================"
