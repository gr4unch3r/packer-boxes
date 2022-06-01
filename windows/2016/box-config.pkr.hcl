variable "cloud_token" {
  type                      = string
  default                   = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "virtualbox-iso" "windows-2016" {
  guest_os_type             = "Windows2016_64"
  headless                  = "true"
  boot_command              = [""]
  boot_wait                 = "6m"
  communicator              = "winrm"
  winrm_username            = "vagrant"
  winrm_password            = "vagrant"
  winrm_timeout             = "6h"
  disk_size                 = "61440"
  hard_drive_interface      = "sata"
  iso_url                   = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.iso"
  iso_checksum              = "772700802951b36c8cb26a61c040b9a8dc3816a3"
  guest_additions_mode      = "attach"
  guest_additions_interface = "sata"
  guest_additions_url       = ""
  floppy_files              = [
      "../answer_files/2016/Autounattend.xml",
      "../floppy/base_setup.ps1"
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
  sources = ["source.virtualbox-iso.windows-2016"]
  provisioner "chef-solo" {
    cookbook_paths = ["../cookbooks"]
    guest_os_type  = "windows"
    run_list       = [
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
    cookbook_paths = ["../cookbooks"]
    guest_os_type  = "windows"
    run_list       = [
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
    cookbook_paths = ["$../cookbooks"]
    guest_os_type  = "windows"
    run_list       = [
        "packer::cleanup", 
        "packer::defrag"
    ]
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "../scripts/cleanup.ps1"
  }
  post-processors {
    post-processor "vagrant" {
      output                = "../builds/windows-2016-{{.Provider}}.box"
      vagrantfile_template  = "../tpl/vagrantfile.tpl"
      compression_level     = "9"
      keep_input_artifact   = false
    }
    post-processor "vagrant-cloud" {
      access_token          = "${var.cloud_token}"
      box_tag               = "gr4unch3r/windows-2016"
      keep_input_artifact   = false
      version               = "10.0.14393"
      version_description   = "**Windows Server Version:** 2016 Datacenter Enterprise Evaluation <br/><br/> **Source:** [https://github.com/gr4unch3r/packer-boxes](https://github.com/gr4unch3r/packer-boxes)"
    }
  }
}
