#!/bin/bash
# =============================================
# VT2 libpci Installer Script
# Version: 2.1 (PERMISSION + ERROR 126 FIX)
# =============================================

SCRIPT_VERSION="2.1"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}VT2 libpci Installer${NC}"
echo -e "${BLUE}Version: ${SCRIPT_VERSION}${NC}"
echo -e "${BLUE}======================================${NC}"

# -------------------------------
# Install required tools
# -------------------------------
install_if_missing() {
    local cmd=$1
    local pkg=$2
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing $pkg...${NC}"
        sudo crew install -y "$pkg" || echo -e "${RED}Failed to install $pkg (continuing)${NC}"
    else
        echo -e "${GREEN}$cmd OK${NC}"
    fi
}

echo -e "${BLUE}Checking tools...${NC}"
install_if_missing gcc gcc
install_if_missing make make
install_if_missing tar tar
install_if_missing xz xz
install_if_missing curl curl

# -------------------------------
# Download pciutils
# -------------------------------
echo -e "${BLUE}Downloading pciutils...${NC}"
URL="https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.14.0.tar.xz"

if ! curl -f -sSL -o /tmp/pciutils.tar.xz "$URL"; then
    echo -e "${RED}Download failed${NC}"
    exit 1
fi

echo -e "${GREEN}Download OK${NC}"

# -------------------------------
# Extract
# -------------------------------
echo -e "${BLUE}Extracting...${NC}"
cd /tmp || exit 1

tar -xJf pciutils.tar.xz || {
    echo -e "${RED}Extraction failed${NC}"
    exit 1
}

cd pciutils-3.14.0 || {
    echo -e "${RED}Folder missing${NC}"
    exit 1
}

# -------------------------------
# FIX PERMISSIONS (important)
# -------------------------------
echo -e "${BLUE}Fixing permissions...${NC}"
chmod -R +x .

# -------------------------------
# Build
# -------------------------------
echo -e "${BLUE}Building libpci...${NC}"

# VT2 sometimes blocks execution → force bash
if make PREFIX=/usr/local CC=gcc; then
    echo -e "${GREEN}Build OK${NC}"
else
    echo -e "${RED}Build failed (error 126 likely)${NC}"
    echo -e "${YELLOW}Trying fallback build...${NC}"
    
    # fallback: force shell execution
    make PREFIX=/usr/local SHELL=/bin/bash CC=gcc || {
        echo -e "${RED}Fallback build failed${NC}"
        exit 1
    }
}

# -------------------------------
# Install (needs sudo)
# -------------------------------
echo -e "${BLUE}Installing...${NC}"
if sudo make PREFIX=/usr/local install; then
    echo -e "${GREEN}Install OK${NC}"
else
    echo -e "${RED}Install failed${NC}"
    exit 1
fi

# -------------------------------
# Final environment fix
# -------------------------------
echo -e "${BLUE}Setting environment...${NC}"
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"

# -------------------------------
# Done
# -------------------------------
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}libpci installed successfully!${NC}"
echo -e "${GREEN}/usr/local/include/pci${NC}"
echo -e "${GREEN}/usr/local/lib/libpci.*${NC}"
echo -e "${BLUE}======================================${NC}"
