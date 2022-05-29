variable "cloud_token" {
  type                    = string
  default                 = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "virtualbox-iso" "debian-bullseye" {
  boot_command            = [
      "<esc><wait>",
      "install <wait>",
      " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
      "debian-installer=en_US.UTF-8 <wait>",
      "auto <wait>",
      "locale=en_US.UTF-8 <wait>",
      "kbd-chooser/method=us <wait>",
      "keyboard-configuration/xkb-keymap=us <wait>",
      "netcfg/get_hostname={{ .Name }} <wait>",
      "netcfg/get_domain=vagrantup.com <wait>",
      "fb=false <wait>",
      "debconf/frontend=noninteractive <wait>",
      "console-setup/ask_detect=false <wait>",
      "console-keymaps-at/keymap=us <wait>",
      "grub-installer/bootdev=default <wait>",
      "<enter><wait>"
      ]
  boot_wait               = "5s"
  cpus                    = "2"
  disk_size               = "65536"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_url     = ""
  guest_os_type           = "Debian_64"
  hard_drive_interface    = "sata"
  headless                = "true"
  http_directory          = "../http"
  iso_checksum            = "sha256:7892981e1da216e79fb3a1536ce5ebab157afdd20048fe458f2ae34fbc26c19b"
  iso_url                 = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso"
  memory                  = "1024"
  shutdown_command        = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "debian-11.3-amd64"
}

build {
  sources                 = ["source.virtualbox-iso.debian-bullseye"]
  provisioner "shell" {
    execute_command       = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect     = true
    scripts               = [
        "../scripts/update.sh", 
        "../scripts/sshd.sh", 
        "../scripts/networking.sh", 
        "../scripts/sudoers.sh", 
        "../scripts/vagrant.sh", 
        "../scripts/systemd.sh", 
        "../scripts/virtualbox.sh", 
        "../scripts/cleanup.sh", 
        "../scripts/minimize.sh"
    ]
  }
  post-processors {
    post-processor "vagrant" {
      output              = "../builds/debian-11.3-{{.Provider}}.box"
      compression_level   = "9"
      keep_input_artifact = false
    }
    post-processor "vagrant-cloud" {
      access_token        = "${var.cloud_token}"
      box_tag             = "gr4unch3r/debian-bullseye"
      keep_input_artifact = false
      version             = "11.3.0"
      version_description = "**Debian Version:** 11.3.0 <br/><br/> **Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
