#!/bin/bash
set -e

[ "$EUID" -ne 0 ] && { echo "must be root"; exit 1; }

export DEBIAN_FRONTEND=noninteractive

BUILD_DEPS=(qemu-user-static qemu-system-riscv64 binfmt-support dpkg-cross \
  arch-test mmdebstrap fakechroot libfakeroot:riscv64 libfakechroot:riscv64 \
  libconfuse-dev debhelper devscripts libssl-dev:riscv64 \
  u-boot-tools gcc-riscv64-linux-gnu libc6-dev-riscv64-cross kmod \
  pkg-config build-essential ninja-build automake autoconf \
  libtool wget curl git gcc libssl-dev bc squashfs-tools android-sdk-libsparse-utils \
  jq python3-setuptools scons parallel tree python3-dev python3-pip device-tree-compiler ssh \
  cpio fakeroot flex bison libncurses5-dev genext2fs rsync unzip dosfstools mtools \
  tcl openssh-client cmake expect libconfuse2)
MISSING_DEPS=()

dpkg --add-architecture riscv64
cat >/etc/apt/sources.list.d/riscv64.sources <<EOF
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Architectures: riscv64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

cat >/etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Architectures: amd64  
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

apt-get update
apt-get install software-properties-common -y
add-apt-repository ppa:queenkjuul/milkv-duos -y -n
sed -i 's/noble/jammy/g' /etc/apt/sources.list.d/queenkjuul-ubuntu-milkv-duos-noble.sources
apt-get update
apt-get upgrade -y

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

if ! which genimage && [ -z $DOCKER_BUILD ];then
    echo "Installing genimage..."
    [ -d ../genimage ] && cd ../genimage || cd genimage
    ./autogen.sh
    ./configure
    make
    make install
    echo "OK."
fi