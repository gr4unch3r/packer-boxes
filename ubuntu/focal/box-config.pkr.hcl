variable "cloud_token" {
  type                    = string
  default                 = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "virtualbox-iso" "ubuntu-focal" {
  boot_command            = [
      " <wait>",
      " <wait>",
      " <wait>",
      " <wait>",
      " <wait>",
      "<esc><wait>",
      "<f6><wait>",
      "<esc><wait>",
      "<bs><bs><bs><bs><wait>",
      " autoinstall<wait5>",
      " ds=nocloud-net<wait5>",
      ";s=http://<wait5>{{.HTTPIP}}<wait5>:{{.HTTPPort}}/<wait5>",
      " ---<wait5>",
      "<enter><wait5>"
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
  iso_checksum            = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
  iso_url                 = "https://releases.ubuntu.com/focal/ubuntu-20.04.4-live-server-amd64.iso"
  memory                  = "1024"
  shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "ubuntu-20.04-amd64"
}

build {
  sources                 = ["source.virtualbox-iso.ubuntu-focal"]
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
      output              = "../builds/ubuntu-20.04-{{.Provider}}.box"
      compression_level   = "9"
      keep_input_artifact = false
    }
    post-processor "vagrant-cloud" {
      access_token        = "${var.cloud_token}"
      box_tag             = "gr4unch3r/ubuntu-focal"
      keep_input_artifact = false
      version             = "20.04.4"
      version_description = "**Ubuntu Version:** 20.04.4 <br/><br/> **Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
