#!/bin/bash

BOARD=$1
HNAME=$2
PASSWORD=$3

[ -z $BOARD ] && { echo "No board!"; exit 1; }
[ -z $HNAME ] && { echo "No hostname!"; exit 1; }
[ -z $PASSWORD ] && { echo "No password!"; exit 1; }

PACKAGES="util-linux haveged openssh-server systemd kmod \
  conntrack ebtables ethtool iproute2 curl \
  iptables mount socat iputils-ping vim dhcpcd5 neofetch sudo chrony \
  nano git fish" # this line optional, add or change your own here

apt-get update && apt-get upgrade -y || { echo "failed to update packages"; exit 1; }
ls /*.deb | grep -v "milkv-pinmux-*" | xargs apt-get install -y
apt-get install \
  --no-install-recommends \
  -y \
  $PACKAGES

if [ ! $BOARD = duos ]; then
  echo "Sorry, $BOARD support coming soon" && exit 1
else
  apt-get install /milkv-pinmux-$BOARD*.deb
fi

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

echo -n "Setting up root credentials..."
echo "root:$PASSWORD" | chpasswd
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
echo "OK"

echo -n "Preparing system for first boot..."
rm -f /etc/ssh/ssh_host_*_key*
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
ExecStart=echo "$HNAME" > /etc/hostname
ExecStart=echo "First Boot: Generating SSH keys"
ExecStart=ssh-keygen -A
ExecStart=echo -n "First Boot: Expanding root partition..."
ExecStart=parted -s -a opt /dev/mmcblk0 "resizepart 3 100%"
ExecStart=resize2fs /dev/mmcblk0p3
ExecStart=echo "OK."
ExecStart=echo "First Boot: Fixing mandb"
ExecStart=chown -R man:root /var/cache/man
ExecStart=runuser -u man -- mandb -q
ExecStart=systemctl disable milkv-first-boot.service

[Install]
WantedBy=basic.target
EOF
systemctl enable milkv-first-boot.service
# Ubuntu-specific; versions newer than 22.04 won't run on cv18xx, 
# we don't want to encourage users to upgrade.
rm /etc/update-motd.d/91-release-upgrade
echo "OK."

echo -n "Cleaning up..."
rm /*.deb
rm /second-stage.sh
echo "OK."
echo "Second stage rootfs setup complete."