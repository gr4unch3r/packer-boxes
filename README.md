# Vagrant Box Packer Builds

[![CI](https://github.com/gr4unch3r/packer-boxes/actions/workflows/ci.yml/badge.svg)](https://github.com/gr4unch3r/packer-boxes/actions/workflows/ci.yml)

My Packer build templates for Vagrant boxes using the VirtualBox provider.

## Available Boxes

- [gr4unch3r/windows-10](https://app.vagrantup.com/gr4unch3r/boxes/windows-10) - `windows/10`
- [gr4unch3r/windows-2016](https://app.vagrantup.com/gr4unch3r/boxes/windows-2016) - `windows/2016`
- [gr4unch3r/ubuntu-focal](https://app.vagrantup.com/gr4unch3r/boxes/ubuntu-focal) - `ubuntu/focal`
- [gr4unch3r/ubuntu-bionic](https://app.vagrantup.com/gr4unch3r/boxes/ubuntu-bionic) - `ubuntu/bionic`
- [gr4unch3r/debian-bullseye](https://app.vagrantup.com/gr4unch3r/boxes/debian-bullseye) - `debian/bullseye`

## Quick-start

```
$ vagrant init gr4unch3r/<box-name>
$ vagrant up
```

## Requirements

- [Packer](https://www.packer.io/)
- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

## Usage

```
$ git clone https://github.com/gr4unch3r/packer-boxes.git
$ cd packer-boxes/<box-dir>
$ packer build box-config.pkr.hcl
```

> **Note**: This will push the box to Vagrant Cloud; to build locally, remove the `vagrant-cloud` post-processor from the `box-config.pkr.hcl` file.

## License

MIT

## Author Information

gr4unch3r [at] protonmail [dot] com
