#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

VER="`cat $HOME_DIR/.vbox_version`";
ISO="VBoxGuestAdditions_$VER.iso";

# mount the ISO to /tmp/vbox
mkdir -p /tmp/vbox;
mount -o loop $HOME_DIR/$ISO /tmp/vbox;

echo "installing deps necessary to compile kernel modules"
apt-get install -y build-essential dkms bzip2 tar linux-headers-`uname -r`

echo "installing the vbox additions"
# this install script fails with non-zero exit codes for no apparent reason so we need better ways to know if it worked
/tmp/vbox/VBoxLinuxAdditions.run --nox11 || true

if ! modinfo vboxsf >/dev/null 2>&1; then
    echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
    exit 1
fi

echo "unmounting and removing the vbox ISO"
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f $HOME_DIR/*.iso;

echo "removing kernel dev packages and compilers we no longer need"
apt-get remove -y build-essential gcc g++ make libc6-dev dkms linux-headers-`uname -r`

echo "removing leftover logs"
rm -rf /var/log/vboxadd*
