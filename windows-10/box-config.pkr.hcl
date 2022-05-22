variable "cloud_token" {
  type                      = string
  default                   = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "virtualbox-iso" "windows-10" {
  guest_os_type             = "Windows10_64"
  headless                  = "true"
  boot_command              = [""]
  boot_wait                 = "6m"
  communicator              = "winrm"
  winrm_username            = "vagrant"
  winrm_password            = "vagrant"
  winrm_timeout             = "6h"
  disk_size                 = "40000"
  hard_drive_interface      = "sata"
  iso_url                   = "https://software-download.microsoft.com/download/pr/18363.418.191007-0143.19h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
  iso_checksum              = "sha256:9ef81b6a101afd57b2dbfa44d5c8f7bc94ff45b51b82c5a1f9267ce2e63e9f53"
  guest_additions_mode      = "attach"
  guest_additions_interface = "sata"
  guest_additions_url       = ""
  floppy_files              = [
      "./answer_files/Autounattend.xml",
      "./floppy/base_setup.ps1"
      ]
  shutdown_command          = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout          = "15m"
  vboxmanage                = [
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--audio", "none"],
    ["modifyvm", "{{.Name}}", "--memory", "10035"],
    ["modifyvm", "{{.Name}}", "--cpus", "3"]
  ]
}

build {
  sources = ["source.virtualbox-iso.windows-10"]
  provisioner "chef-solo" {
    cookbook_paths          = ["./cookbooks"]
    guest_os_type           = "windows"
    run_list                = [
        "packer::disable_uac",
        "packer::disable_restore",
        "packer::disable_windows_update",
        "packer::disable_defender",
        "packer::configure_power",
        "packer::disable_screensaver"
    ]
  }
  provisioner "windows-restart" {
  }
  provisioner "chef-solo" {
    cookbook_paths          = ["./cookbooks"]
    guest_os_type           = "windows"
    run_list                = [
        "packer::vm_tools",
        "packer::features",
        "packer::enable_file_sharing",
        "packer::enable_remote_desktop",
        "packer::ui_tweaks"
    ]
  }
  provisioner "windows-restart" {
  }
  provisioner "chef-solo" {
    cookbook_paths          = ["./cookbooks"]
    guest_os_type           = "windows"
    run_list                = [
        "packer::cleanup",
        "packer::defrag"
    ]
  }
  provisioner "powershell" {
    script                  = "./scripts/cleanup.ps1"
    elevated_user           = "vagrant"
    elevated_password       = "vagrant"
  }
  post-processors {
    post-processor "vagrant" {
      output                = "./builds/windows-10-{{.Provider}}.box"
      vagrantfile_template  = "./vagrantfile.tpl"
      compression_level     = "9"
      keep_input_artifact   = false
    }
    post-processor "vagrant-cloud" {
      access_token          = "${var.cloud_token}"
      box_tag               = "gr4unch3r/windows-10"
      keep_input_artifact   = false
      version               = "0.1.0"
      version_description   = "**Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
