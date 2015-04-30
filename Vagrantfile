# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "centos6.5"

    config.hostmanager.enabled = true
    config.vm.hostname = 'docker-host'
    config.vm.define "docker-host"

    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
    config.vm.synced_folder "./docker_data", "/docker_data", create: true
    config.vm.synced_folder "./server_key", "/server_key"
    config.omnibus.chef_version = :latest

    config.vm.provision "chef_solo" do |chef|
        chef.add_recipe "docker"
        chef.json = {
          "docker" => {
            'group_members' => ['vagrant'],
            'selinux_enabled' => false,
            'options' => '-g /docker_data'
          }
        }
    end
end
