# -*- mode: ruby -*-
# vi: set ft=ruby :

# Temporary workaround to Python bug in macOS High Sierra which can break Ansible
# https://github.com/ansible/ansible/issues/34056#issuecomment-352862252
# This is an ugly hack tightly bound to the internals of Vagrant.Util.Subprocess, specifically
# the jailbreak method, self-described as "quite possibly, the saddest function in all of Vagrant."
# That in turn makes this assignment the saddest line in all of Vagrantfiles.
ENV["VAGRANT_OLD_ENV_OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES"

Vagrant.configure(2) do |config|
    config.vm.define "vagrant-windows-10"
    config.vm.box = "windows-10"
    config.vm.guest = :windows
    config.windows.halt_timeout = 15
    config.vm.communicator = "winrm"
    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"
    config.vm.boot_timeout = 300
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
    config.vm.provider :virtualbox do |v, override|
        #v.gui = true
        v.customize ["modifyvm", :id, "--memory", 4096]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--vram", 128]
        v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
        v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
end
