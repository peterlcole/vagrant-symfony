# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.configure(2) do |config|

  projectConfig  = YAML.load_file('VagrantConfig.yml')

  # Configure the VM
  config.vm.box     = "ubuntu/trusty64"
  config.vm.network   "private_network", type: "dhcp"

  useNfs = ! Vagrant::Util::Platform.windows?

  config.nfs.map_uid = Process.uid
  config.nfs.map_gid = Process.gid 

  projectConfig['folders'].each do |folder|
    config.vm.synced_folder folder["host"], folder["guest"], create: true, :nfs => useNfs
  end

  projectConfig['ports'].each do |port|
    config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], auto_correct: true
  end

  config.vm.provision "shell", path: "config/bootstrap.sh"

end
