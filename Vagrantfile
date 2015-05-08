# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "centos65_docker"

    config.hostmanager.enabled = true
    config.vm.hostname = 'docker-host'
    config.vm.define "docker-host"
    config.vm.network :private_network, :ip => '192.168.100.100'
    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        file_disk = "./docker_data/disk.vdi"
        unless File.exist?(file_disk)
          vb.customize ['createhd', '--filename', file_disk, '--size', 100 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_disk]
    end
    config.vm.synced_folder "./docker_data", "/docker"
    config.vm.synced_folder "./log/docker", "/docker_log", create: true
    config.vm.synced_folder "./proj" , "/proj"
    config.vm.synced_folder "./server_key", "/server_key"
    config.omnibus.chef_version = :latest

    config.vm.provision "chef_solo" do |chef|
        chef.add_recipe "htop"
        chef.add_recipe "btrfs"
        chef.add_recipe "docker"
        chef.json = {
          "docker" => {
            'version' => "1.6.0-1.el6",
            'auto_start' => false,
            'get_official_binary' => true,
            'group_members' => ['vagrant'],
            'logfile' => '/docker_log/docker.log',
            'options' => '-s btrfs'
          }
        }
    end
end
