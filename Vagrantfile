Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
    config.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
      libvirt.host = 'localhost'
      libvirt.uri = 'qemu:///system'
      libvirt.memory = 1024
      libvirt.cpus = 2
      libvirt.title = "archlinux"
    end
end
