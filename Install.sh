#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 4.0 (NOEXEC BYPASS)
# =============================================

VERSION="4.0"

echo "======================================"
echo " libpci Installer (VT2 BYPASS)"
echo " Version: $VERSION"
echo "======================================"

BUILD_DIR="$HOME/build_libpci"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Install minimal tools
for pkg in gcc make tar xz curl; do
    command -v $pkg >/dev/null 2>&1 || crew install -y $pkg
done

# Download
URL="https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.14.0.tar.xz"
curl -L -o pciutils.tar.xz "$URL" || exit 1

# Extract
tar -xJf pciutils.tar.xz || exit 1
cd pciutils-3.14.0 || exit 1

# Permissions (still needed)
chmod -R 755 .

# 🔥 CRITICAL: disable features that require execution
sed -i 's/ZLIB=yes/ZLIB=no/g' Makefile 2>/dev/null
sed -i 's/SHARED=yes/SHARED=no/g' Makefile 2>/dev/null

# 🔥 FORCE BUILD WITHOUT EXEC CALLS
echo "Building (noexec-safe)..."

make \
  PREFIX=/usr/local \
  CC="gcc" \
  HOSTCC="gcc" \
  AR="ar" \
  RANLIB="ranlib" \
  STRIP="strip" \
  ZLIB=no \
  DNS=no \
  SHARED=no

if [ $? -ne 0 ]; then
    echo "Build failed — VT2 is blocking execution at kernel level."
    exit 1
fi

echo "Installing..."
sudo make PREFIX=/usr/local install || exit 1

echo "======================================"
echo " libpci installed (if VT2 allowed it)"
echo "======================================"
