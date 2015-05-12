# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'pathname'

VAGRANT_COMMAND = ARGV[0]

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

  @status = nil
  if not File.exist?(backup_path) and not File.exist?(file_path)
    @status = 0
  elsif File.exist?(backup_path) and not File.exist?(file_path) #restore from backup path
    if VAGRANT_COMMAND == "up"
      puts "restore from backuped docker content disk"
    end
    FileUtils.cp(backup_path, file_path)
    @status = 1
  else
    @status = 2 #normal boot up after everything is ready
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]

    if @status == 0 # no existing file and no already backuped file.
      if VAGRANT_COMMAND == "up"
        puts "create new docker content disk file"
      end
      vb.customize ['createhd', '--filename', file_path, '--size', 100 * 1024]
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_path]
    elsif @status == 1 #restore from backup path
      if VAGRANT_COMMAND == "up"
        puts "attach #{file_path} disk image file"
      end
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
        confirm = ask "Warning! Docker data disk should be backuped to #{backup_path} before VM delete!\r\nBackup the Docker data disk? (Y/N) "
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
    if @status == 0
      chef.add_recipe "prepare_disk::new_disk"
      chef.add_recipe "prepare_disk::mount"
    elsif @status == 1
      chef.add_recipe "prepare_disk::restore_disk"
      chef.add_recipe "prepare_disk::mount"
    end
    chef.add_recipe "docker::compose"
    chef.add_recipe "docker::docker-enter"

    chef.json = {
      "docker" => {
        'version' => "1.6.0-1.el6",
        'auto_start' => false,
        'get_official_binary' => true,
        'group_members' => ['vagrant'],
        'logfile' => '/docker_log/docker.log',
        'options' => '-s btrfs'
      },
      "prepare_disk" => {
        'physic_dev_path' => '/dev/sdb',
        'logic_volume_group' => 'docker_btrfs',
        'logic_volume' => 'docker_btrfs01',
        'format_fs' => 'btrfs'
      }
    }
  end

  config.vm.provision "relink-config", type: "chef_solo", run: "always" do |chef|
    chef.add_recipe "docker::start_host"
  end

end
