#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 1.2
# =============================================

SCRIPT_VERSION="1.2"

# -------------------------------
# Colors
# -------------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}VT2 libpci Installer${NC}"
echo -e "${BLUE}Script Version: ${SCRIPT_VERSION}${NC}"
echo -e "${BLUE}======================================${NC}"

# -------------------------------
# Dependency check and install
# -------------------------------
install_if_missing() {
    local cmd=$1
    local pkg=$2
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${YELLOW}$cmd not found. Installing $pkg via Chromebrew...${NC}"
        if ! crew install "$pkg"; then
            echo -e "${RED}WARNING: Failed to install $pkg. The script will continue, but you may need to fix it manually.${NC}"
        else
            echo -e "${GREEN}$pkg installed successfully.${NC}"
        fi
    else
        echo -e "${GREEN}$cmd already installed.${NC}"
    fi
}

echo -e "${BLUE}Step 1: Checking build tools...${NC}"
install_if_missing gcc gcc
install_if_missing g++ g++
install_if_missing make make
install_if_missing pkg-config pkg-config

# -------------------------------
# Download pciutils
# -------------------------------
echo -e "${BLUE}Step 2: Downloading pciutils (for libpci)...${NC}"
PCIUTILS_URL="https://mj.ucw.cz/sw/pciutils/pciutils-3.14.tar.gz"

download_success=false
for i in {1..3}; do
    echo -e "${YELLOW}Attempt $i: downloading...${NC}"
    if curl -f -sSL -o /tmp/pciutils.tar.gz "$PCIUTILS_URL"; then
        download_success=true
        break
    else
        echo -e "${RED}Download failed, retrying...${NC}"
        sleep 2
    fi
done

if [ "$download_success" = false ]; then
    echo -e "${RED}ERROR: Failed to download pciutils after 3 attempts. Exiting.${NC}"
    exit 1
else
    echo -e "${GREEN}pciutils downloaded successfully.${NC}"
fi

# -------------------------------
# Extract and compile pciutils
# -------------------------------
echo -e "${BLUE}Step 3: Extracting pciutils...${NC}"
cd /tmp
tar -xzf pciutils.tar.gz || { echo -e "${RED}ERROR: Failed to extract pciutils.${NC}"; exit 1; }
cd pciutils-3.14 || { echo -e "${RED}ERROR: pciutils folder missing.${NC}"; exit 1; }

echo -e "${BLUE}Step 4: Setting compiler/linker paths...${NC}"
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

echo -e "${BLUE}Step 5: Configuring, compiling, and installing libpci...${NC}"
if ./configure --prefix=/usr/local && make && sudo make install; then
    echo -e "${GREEN}libpci installed successfully!${NC}"
else
    echo -e "${RED}WARNING: Failed to build/install libpci. Check errors above.${NC}"
fi

# -------------------------------
# Completion
# -------------------------------
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}libpci Headers: /usr/local/include/pci${NC}"
echo -e "${GREEN}libpci Libraries: /usr/local/lib/libpci.*${NC}"
echo -e "${BLUE}Your VT2 environment is now ready to compile projects requiring libpci.${NC}"
echo -e "${BLUE}Script version: ${SCRIPT_VERSION}${NC}"
echo -e "${BLUE}======================================${NC}"
