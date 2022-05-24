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
  disk_size                 = "61440"
  hard_drive_interface      = "sata"
  iso_url                   = "https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
  iso_checksum              = "sha256:27e4feb9102f7f2b21ebdb364587902a70842fb550204019d1a14b120918e455"
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
    post-processor "checksum" {
      checksum_types        = [
        "sha512"
      ]
      output                = "./builds/packer_{{.BuildName}}_{{.BuilderType}}_{{.ChecksumType}}.checksum"
    }
    post-processor "vagrant-cloud" {
      access_token          = "${var.cloud_token}"
      box_tag               = "gr4unch3r/windows-10"
      keep_input_artifact   = false
      checksum              = "sha512:{$checksum}"
      version               = "10.0.17134"
      version_description   = "**Windows 10 Version:** 1803 Enterprise Evaluation <br/><br/> **Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
