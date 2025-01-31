# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "almalinux/9"
  config.vm.box_version = "9.5.20241203"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  mirrors = ["archlinux", "debian"]

  mirrors.each do |mirror|
    host = mirror + '1'
    config.vm.define host do |node|
      node.vm.hostname = host

      node.vm.provider :libvirt do |libvirt|
        libvirt.memory = 4096
        libvirt.cpus = 4
        libvirt.cputopology sockets: '1', cores: '4', threads: '1'
        libvirt.graphics_type = "none"
      end

      node.vm.provision "ansible" do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "site.yml"
        ansible.groups = {
          "mirrors:children" => [mirror],
          mirror => [host],
        }
        ansible.extra_vars = "vagrant.yml"
      end
    end
  end
end
