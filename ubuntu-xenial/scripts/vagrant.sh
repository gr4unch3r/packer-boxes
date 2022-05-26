#!/bin/bash -eux

pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub";
mkdir -p /home/vagrant/.ssh;
if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate "$pubkey_url" -O /home/vagrant/.ssh/authorized_keys;
elif command -v curl >/dev/null 2>&1; then
    curl --insecure --location "$pubkey_url" > /home/vagrant/.ssh/authorized_keys;
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chown -R vagrant /home/vagrant/.ssh;
chmod -R go-rwsx /home/vagrant/.ssh;
