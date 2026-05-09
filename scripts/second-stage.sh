#!/bin/bash

BOARD=$1
HNAME=$2

[ -z $BOARD ] && { echo "No board!"; exit 1; }
[ -z $HNAME ] && { echo "No hostname!"; exit 1; }

# Core system
PACKAGES="util-linux haveged openssh-server systemd kmod \
  conntrack nftables ethtool iproute2 curl python3-pip \
  mount socat iputils-ping vim neofetch sudo chrony fake-hwclock \
  milkv-dt-overlays milkv-arduino \
  linux-image-milkv-$BOARD milkv-usb-$BOARD milkv-pinmux-$BOARD"
# Board-specific
DUOS_PACKAGES="aic8800-milkv-firmware aic8800-milkv-modules-$BOARD milkv-wireless-$BOARD"
# User - season to taste
USER_PACKAGES="nano git python-is-python3 impala bluetui sacad devmem2"

if [ "$BOARD" = "duos" ]; then
  PACKAGES="$PACKAGES $DUOS_PACKAGES"
fi

mv /queenkjuul-ubuntu-milkv.gpg /etc/apt/trusted.gpg.d/queenkjuul-ubuntu-milkv-$BOARD.gpg
chmod 644 /etc/apt/trusted.gpg.d/queenkjuul-ubuntu-milkv-$BOARD.gpg
apt-get update || { echo "failed to update packages"; exit 1; }

LOCAL_DEBS=$(ls /*.deb | grep -v "milkv-pinmux-" || echo "")
LOCAL_PACKAGES=
for deb in $LOCAL_DEBS; do
  LOCAL_PACKAGES="$LOCAL_PACKAGES $(dpkg-deb -f "$deb" Package)"
done
TARGET_PACKAGES=
for pkg in $PACKAGES; do
  [[ " $LOCAL_PACKAGES " =~ " $pkg " ]] || TARGET_PACKAGES="$TARGET_PACKAGES $pkg"
done
echo "Installing $TARGET_PACKAGES $USER_PACKAGES"
apt-get install \
  --no-install-recommends \
  --allow-downgrades \
  -y \
  $LOCAL_DEBS $TARGET_PACKAGES $USER_PACKAGES

[ -f /milkv-pinmux-$BOARD_*.deb ] \
  && apt-get install -y /milkv-pinmux-$BOARD*.deb \
  || apt-get install -y milkv-pinmux-$BOARD

# comment next two lines to disable zram
apt-get install -y zram-config
systemctl enable zram-config

echo -n "Fixing symlinks..."
find / -type l -exec ln -sfr {} {} \;
ln -snf ../../../etc/ssl/certs /usr/lib/ssl/certs
ln -snf ../../../etc/ssl/private /usr/lib/ssl/private
ln -snf ../run /var/run
ln -snf ../run/lock /var/lock
echo "OK."

echo -n "Setting up network..."
cat >/etc/systemd/network/20-wired.network <<EOF
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

ln -sfr /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
cat >/etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=8.8.8.8
EOF

echo "$HNAME" > /etc/hostname

systemctl enable systemd-networkd
systemctl enable systemd-resolved
echo "OK"

echo -n "Writing fstab..."
cat >/etc/fstab <<EOF
# <file system>	<mount pt>	<type>	<options>	<dump>	<pass>
/dev/root	/		ext4	rw	0	1
/dev/mmcblk0p1  /boot/vendor vfat  rw  0 1
proc		/proc		proc	defaults	0	0
devpts		/dev/pts	devpts	defaults,gid=5,mode=620,ptmxmode=0666	0	0
tmpfs		/dev/shm	tmpfs	mode=0777	0	0
tmpfs		/tmp		tmpfs	mode=1777	0	0
tmpfs		/run		tmpfs	mode=0755,nosuid,nodev,size=64M	0	0
sysfs		/sys		sysfs	defaults	0	0
EOF
echo "OK"

echo -n "Enabling SSH login for root..."
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo "OK"

echo -n "Preparing system for first boot..."
rm -f /etc/ssh/ssh_host_*_key*
mkdir -p /usr/libexec/milkv
mv /first-boot.sh /usr/libexec/milkv/first-boot.sh
cat >/lib/systemd/system/milkv-first-boot.service <<EOF
[Unit]
Description=Milk-V Duo First Boot Setup
Requires=local-fs.target
After=local-fs.target
Before=basic.target
ConditionFirstBoot=yes
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
StandardOutput=journal+console
StandardError=journal
ExecStart=/usr/libexec/milkv/first-boot.sh

[Install]
WantedBy=basic.target
EOF
systemctl enable milkv-first-boot.service
# Ubuntu-specific; versions newer than 24.04 won't run on cv18xx, 
# we don't want to encourage users to upgrade.
rm /etc/update-motd.d/91-release-upgrade
if [ "$BOARD" = "duos" ]; then
# pwmchip0/pwm0 is hard-wired internally to the buck converter
# if you try to write to it via sysfs, you crash the whole board
cat >/etc/udev/rules.d/99-pwm0-protect.rules <<EOF
SUBSYSTEM=="pwm", KERNELS=="3060000.pwm", ACTION=="change", RUN+="/bin/sh -c 'if [ -d /sys%p/pwm0 ]; then chmod 400 /sys%p/pwm0/period /sys%p/pwm0/enable /sys%p/pwm0/duty_cycle; fi'"
EOF
fi
echo "OK."

echo -n "Cleaning up..."
rm /*.deb || true
rm /second-stage.sh
echo "OK."
echo "Second stage rootfs setup complete."