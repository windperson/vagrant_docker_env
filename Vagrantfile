# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'pathname'

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "centos65_docker"
  config.ssh.insert_key = false
  config.hostmanager.enabled = true
  config.vm.hostname = 'docker-host'
  config.vm.define "docker-host"
  config.vm.network :private_network, :ip => '192.168.100.100'
  file_disk = "disk.vdi"
  attach_dir = "./docker_data"
  backup_dir = "./docker_backup"
  file_path = Pathname.new(attach_dir).join(file_disk)
  backup_path = Pathname.new(backup_dir).join(file_disk)

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]

    if not File.exist?(backup_path) and not File.exist?(file_path) # no existing file and no already backuped file.
      # puts "create new docker content disk file"
      vb.customize ['createhd', '--filename', file_path, '--size', 100 * 1024]
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_path]
    elsif File.exist?(backup_path) and not File.exist?(file_path) #restore from backup path
      puts "restore from backuped docker content disk"
      FileUtils.cp(backup_path, file_path)
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_path]
    end
  end

  config.vm.synced_folder "./log/docker", "/docker_log", create: true
  config.vm.synced_folder "./proj" , "/proj"
  config.vm.synced_folder "./server_key", "/server_key"

  config.trigger.before :destroy do
    if File.exist?(file_path)
      confirm = nil
      until ["Y", "y", "N", "n"].include?(confirm)
        confirm = ask "Warning! Docker data disk should be backuped to #{backup_path} before VM delete! Would you want to backup the Docker data disk? (Y/N) "
      end
      if confirm.upcase == "Y"
        FileUtils.cp(file_path, backup_path)
      end
    end
  end

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
