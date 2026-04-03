#!/bin/bash
set -e

[ "$EUID" -ne 0 ] && { echo "must be root"; exit 1; }

export DEBIAN_FRONTEND=noninteractive

# everything after u-boot-tools is from duo-buildroot-sdk-v2 and may not strictly be necessary
BUILD_DEPS=(qemu qemu-user-static binfmt-support dpkg-cross \
  arch-test mmdebstrap libfakeroot:riscv64 libfakechroot:riscv64 \
  libconfuse-dev debhelper devscripts \
  u-boot-tools \
  pkg-config build-essential ninja-build automake autoconf \
  libtool wget curl git gcc libssl-dev bc slib squashfs-tools android-sdk-libsparse-utils \
  jq python3-distutils scons parallel tree python3-dev python3-pip device-tree-compiler ssh \
  cpio fakeroot libncurses5 flex bison libncurses5-dev genext2fs rsync unzip dosfstools mtools \
  tcl openssh-client cmake expect libconfuse2)
MISSING_DEPS=()

dpkg --add-architecture riscv64
cat >/etc/apt/sources.list <<EOF
# Standard amd64 repos
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb [arch=amd64] http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb [arch=amd64] http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# RISC-V ports repos
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb [arch=riscv64] http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
EOF
add-apt-repository ppa:queenkjuul/milkv-duos

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
if [ ! ${#MISSING_DEPS[@]} -eq 0 ]; then
    apt-get install --no-install-recommends -y "${MISSING_DEPS[@]}"
fi
echo "OK."

echo "Installing genimage..."
cd genimage
./autogen.sh
./configure
make
make install
echo "OK."