variable "cloud_token" {
  type                    = string
  default                 = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "virtualbox-iso" "ubuntu-bionic" {
  boot_command            = [
        "<esc><wait>",
        "<esc><wait>",
        "<enter><wait>",
        "/install/vmlinuz<wait>",
        " auto<wait>",
        " console-setup/ask_detect=false<wait>",
        " console-setup/layoutcode=us<wait>",
        " console-setup/modelcode=pc105<wait>",
        " debconf/frontend=noninteractive<wait>",
        " debian-installer=en_US.UTF-8<wait>",
        " fb=false<wait>",
        " initrd=/install/initrd.gz<wait>",
        " kbd-chooser/method=us<wait>",
        " keyboard-configuration/layout=USA<wait>",
        " keyboard-configuration/variant=USA<wait>",
        " locale=en_US.UTF-8<wait>",
        " netcfg/get_domain=vm<wait>",
        " netcfg/get_hostname=vagrant<wait>",
        " grub-installer/bootdev=/dev/sda<wait>",
        " noapic<wait>",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
        " -- <wait>",
        "<enter><wait>"
      ]
  boot_wait               = "5s"
  cpus                    = "2"
  disk_size               = "65536"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_url     = ""
  guest_os_type           = "Ubuntu_64"
  hard_drive_interface    = "sata"
  headless                = "true"
  http_directory          = "../http"
  iso_checksum            = "sha256:f5cbb8104348f0097a8e513b10173a07dbc6684595e331cb06f93f385d0aecf6"
  iso_url                 = "http://cdimage.ubuntu.com/ubuntu/releases/18.04.6/release/ubuntu-18.04.6-server-amd64.iso"
  memory                  = "1024"
  shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "ubuntu-18.04-amd64"
}

build {
  sources                 = ["source.virtualbox-iso.ubuntu-bionic"]
  provisioner "shell" {
    execute_command       = "echo 'vagrant' | sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect     = true
    scripts               = [
        "../scripts/update.sh", 
        "../scripts/sshd.sh", 
        "../scripts/networking.sh", 
        "../scripts/sudoers.sh", 
        "../scripts/vagrant.sh", 
        "../scripts/virtualbox.sh", 
        "../scripts/cleanup.sh", 
        "../scripts/minimize.sh"
        ]
  }
  post-processors {
    post-processor "vagrant" {
      output              = "../builds/ubuntu-18.04-{{.Provider}}.box"
      compression_level   = "9"
      keep_input_artifact = false
    }
    post-processor "vagrant-cloud" {
      access_token        = "${var.cloud_token}"
      box_tag             = "gr4unch3r/ubuntu-bionic"
      keep_input_artifact = false
      version             = "18.04.6"
      version_description = "**Ubuntu Version:** 18.04.6 <br/><br/> **Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
