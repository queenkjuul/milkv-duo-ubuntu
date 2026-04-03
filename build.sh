#! /bin/bash
set -e

RELEASE=jammy
DEFAULT_HNAME=milkv-ubuntu
DEFAULT_PASSWORD=milkv
PKG_URL=http://ports.ubuntu.com/ubuntu-ports
PKG_STE="main restricted universe multiverse"
PKG_SRC="deb $PKG_URL $PKG_STE"
BOARD=duos
PPA_URL=https://ppa.launchpadcontent.net/queenkjuul/milkv-$BOARD/ubuntu

FLAG=$1

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
build.sh - create an Ubuntu image for Milk-V Duo boards

    build.sh [-c | --custom] [-h | --help]

    -h | --help     show this help
    -c | --custom   prompt for settings

default HNAME is "ubuntu-milkv" and default root password is "milkv"
EOF
    exit
fi

if [ "$1" = "--custom" ] || [ "$1" = "-c" ]; then
    [ -z "$HNAME" ] && read -rp "HNAME (optional, default: $DEFAULT_HNAME): " HNAME
    [ -z "$PASSWORD" ] && { read -rsp "root password (optional, default: $DEFAULT_PASSWORD): " PASSWORD; echo; }
fi

[ -z "$HNAME" ] && HNAME=$DEFAULT_HNAME
[ -z "$PASSWORD" ] && PASSWORD=$DEFAULT_PASSWORD

if [ "$PASSWORD" = "$DEFAULT_PASSWORD" ]; then
    DISPLAY_PASSWORD="Default ($DEFAULT_PASSWORD)"
else
    DISPLAY_PASSWORD="Changed by user"
fi

cat <<EOF
==== Ubuntu for Milk-V Duo Boards ====
Selected Configuration:
    Board:          $BOARD
    Package Source: $PKG_URL
    Package Suites: $PKG_STE
    Release:        $RELEASE
    HNAME:          $HNAME
    Password:       $DISPLAY_PASSWORD
======================================
EOF

echo "Running mmdebstrap"
rm -rf rootfs
mkdir rootfs
mmdebstrap --arch=riscv64 \
            --mode=fakechroot \
            --variant=standard \
            --setup-hook=/usr/share/mmdebstrap/hooks/merged-usr/setup00.sh \
            --setup-hook="copy-in ./queenkjuul-ubuntu-milkv-$BOARD.gpg /" \
            --setup-hook="copy-in ./*.deb /" \
            --setup-hook="copy-in ./scripts/second-stage.sh /" \
            --setup-hook="copy-in ./scripts/first-boot.sh /" \
            --customize-hook='chroot "$1" /bin/bash -e /second-stage.sh '$BOARD' '$HNAME' '$PASSWORD \
            $RELEASE rootfs \
            "deb $PKG_URL jammy $PKG_STE" \
            "deb $PKG_URL jammy-backports $PKG_STE" \
            "deb $PKG_URL jammy-security $PKG_STE" \
            "deb $PPA_URL jammy main"

echo -n "Installing Bootloader..."
cp rootfs/boot/boot.sd-* images/boot.sd
echo "OK."

echo "Generating SD Card Image..."
dd if=/dev/zero of=images/swap.img bs=1M count=256
mkswap images/swap.img
fakeroot genimage --rootpath ./rootfs --config ./genimage.cfg --inputpath ./images
echo "SD card image generated at ./images/ubuntu-milkv.img"