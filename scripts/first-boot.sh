#!/bin/bash

echo "First Book: Setting Hostname"
echo "$HNAME" > /etc/hostname

echo -n "First Boot: Update ld cache..."
ldconfig
echo "OK."

echo "First Boot: Generating SSH keys"
ssh-keygen -A

echo -n "First Boot: Expanding root partition..."
parted -s -a opt /dev/mmcblk0 "resizepart 3 100%"
resize2fs /dev/mmcblk0p3
echo "OK."

echo "First Boot: Fixing mandb"
chown -R man:root /var/cache/man
runuser -u man -- mandb -q

systemctl disable milkv-first-boot.service
