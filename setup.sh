#!/bin/bash
set -e

BUILD_DEPS=(qemu qemu-user-static binfmt-support dpkg-cross \
  arch-test mmdebstrap libfakeroot:riscv64 libfakechroot:riscv64 \
  u-boot-tools)
MISSING_DEPS=()

echo "Checking dependencies..."
for pkg in "${BUILD_DEPS[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
        echo "  [ ] $pkg is missing" >&2
        MISSING_DEPS+=("$pkg")
    else
        echo "  [x] $pkg is found" >&2
    fi
done
echo "Installing dependencies..."
[ ! ${#MISSING_DEPS[@]} -eq 0 ] && sudo apt install --no-install-recommends -y "${MISSING_DEPS[@]}"
echo "OK."