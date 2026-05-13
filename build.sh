#! /bin/bash
set -e

RELEASE=noble
DEFAULT_BOARD=duos
DEFAULT_HNAME=milkv-ubuntu
DEFAULT_PASSWORD=milkv
PKG_URL=http://ports.ubuntu.com/ubuntu-ports
PKG_STE="main restricted universe multiverse"
PKG_SRC="deb $PKG_URL $PKG_STE"
OVERDRIVE=.od

FLAG=$1

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
build.sh - create an Ubuntu image for Milk-V Duo boards

    build.sh [-c | --custom] [-h | --help] | [BOARD]

    -h | --help     show this help
    -c | --custom   prompt for settings
    BOARD           one of duos, duos-wifi, duo256m
                    must be only argument

default hostname is "$DEFAULT_HNAME" and default root password is "$DEFAULT_PASSWORD"
default target board is "$DEFAULT_BOARD"
CPU overdrive is enabled by default (1050MHz vs 850MHz vendor default)
EOF
    exit
fi

if [ ! "$FLAG" = "--custom" ] && [ ! "$FLAG" = "-c" ]; then
    BOARD=$1
    echo "BOARD=$BOARD"
else
    while [ ! "$BOARD" = "duos" ] && [ ! "$BOARD" = "duos-wifi" ] && [ ! "$BOARD" = "duo256m" ]; do
        read -rp "target board (required, must be duos or duo256m): " BOARD
    done
    [ -z "$HNAME" ] && read -rp "hostname (optional, default: $DEFAULT_HNAME): " HNAME
    [ -z "$PASSWORD" ] && { read -rsp "root password (optional, default: $DEFAULT_PASSWORD): " PASSWORD; echo; }
    read -rp 'enable CPU overdrive? y = 1050MHz, n = 850MHz (y/n): ' OD
    [ "$OD" = "n" ] && OVERDRIVE=""
fi

[ -z "$BOARD" ] && BOARD=$DEFAULT_BOARD
[ -z "$HNAME" ] && HNAME=$DEFAULT_HNAME
[ -z "$PASSWORD" ] && PASSWORD=$DEFAULT_PASSWORD

if [ "$PASSWORD" = "$DEFAULT_PASSWORD" ]; then
    DISPLAY_PASSWORD="Default ($DEFAULT_PASSWORD)"
else
    DISPLAY_PASSWORD="Changed by user"
fi

PASSWORD=$(echo -n "$PASSWORD" | openssl passwd -6 -stdin)
[ "$OVERDRIVE" = ".od" ] && DISPLAY_OD="Enabled (1050MHz)" || DISPLAY_OD="Disabled (850MHz)"

cat <<EOF
==== Ubuntu for Milk-V Duo Boards ====
Selected Configuration:
    Board:          $BOARD
    Package Source: $PKG_URL
    Package Suites: $PKG_STE
    Release:        $RELEASE
    Hostname:       $HNAME
    Password:       $DISPLAY_PASSWORD
    CPU Overdrive:  $DISPLAY_OD
======================================
EOF

if [ "$BOARD" = "duos-wifi" ]; then
    WIRELESS="true"
    BOARD="duos"
fi

echo "Running mmdebstrap"
PPA_URL=https://ppa.launchpadcontent.net/queenkjuul/milkv-$BOARD/ubuntu
rm -rf rootfs
mkdir -p rootfs
mkdir -p images
mmdebstrap --arch=riscv64 \
            --mode=root \
            --variant=standard \
            --keyring=./queenkjuul-ubuntu-milkv.gpg \
            --setup-hook=/usr/share/mmdebstrap/hooks/merged-usr/setup00.sh \
            --setup-hook="cp *.deb rootfs/ 2>/dev/null || true" \
            --setup-hook="copy-in ./queenkjuul-ubuntu-milkv.gpg /" \
            --setup-hook="copy-in ./scripts/second-stage.sh /" \
            --setup-hook="copy-in ./scripts/first-boot.sh /" \
            --customize-hook='chroot "$1" /bin/bash -e /second-stage.sh '$BOARD' '$HNAME' '$WIRELESS \
            $RELEASE rootfs \
            "deb $PKG_URL $RELEASE $PKG_STE" \
            "deb $PKG_URL $RELEASE-backports $PKG_STE" \
            "deb $PKG_URL $RELEASE-security $PKG_STE" \
            "deb $PPA_URL $RELEASE main"

echo -n "Installing Bootloader..."
cp rootfs/boot/boot.sd-* images/boot.sd
cp milkv-bootloader/$BOARD/fip.bin$OVERDRIVE images/fip.bin
echo "OK."

echo "Resetting Machine ID"
echo "uninitialized" > rootfs/etc/machine-id

echo "Setting root password"
sed -i "s|^root:[^:]*:|root:$PASSWORD:|" ./rootfs/etc/shadow

echo "Generating SD Card Image..."
[ -n "$WIRELESS" ] && BOARD="duos-wifi"
dd if=/dev/zero of=images/swap.img bs=1M count=256
mkswap images/swap.img
fakeroot genimage --rootpath ./rootfs --config ./genimage.cfg --inputpath ./images
mv images/ubuntu-milkv.img images/ubuntu-$RELEASE-milkv-$BOARD.img
echo "SD card image generated at ./images/ubuntu-$RELEASE-milkv-$BOARD.img"