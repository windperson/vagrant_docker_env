# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'pathname'

VAGRANT_COMMAND = ARGV[0]

VAGRANTFILE_API_VERSION = "2" if not defined? VAGRANTFILE_API_VERSION

DOCKER_DISK_SIZE = 100
VM_RAM_SIZE = 1024
VM_CPU_CORE = 1
VG_BOX_NAME = "CentOS7"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #ensure VirtablBox provider as 1st serve.
  config.vm.provider "virtualbox"
  config.vm.provider "parallels"
  config.vm.provider "vmware_fusion"

  config.vm.box = "#{VG_BOX_NAME}"
  if Vagrant.has_plugin?("vagrant-cachier")
    	# Configure cached packages to be shared between instances of the same base box.
    	# More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
      config.cache.scope = :box
      if RUBY_PLATFORM =~ /darwin/
        config.cache.synced_folder_opts = {
          type: :nfs,
          # The nolock option can be useful for an NFSv3 client that wants to avoid the
          # NLM sideband protocol. Without this option, apt-get might hang if it tries
          # to lock files needed for /var/cache/* operations. All of this can be avoided
          # by using NFSv4 everywhere. Please note that the tcp option is not the default.
          mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
        }
      end
  end
  # config.ssh.insert_key = false
  config.vm.hostname = 'docker-host'
  config.vm.define "docker-host"
  config.vm.network :private_network, :ip => '192.168.201.101'
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
    vb.customize ["modifyvm", :id, "--memory", "#{VM_RAM_SIZE}"]
    vb.customize ["modifyvm", :id, "--cpus", "#{VM_CPU_CORE}"]

    if @status == 0 # no existing file and no already backuped file.
      if VAGRANT_COMMAND == "up"
        puts "create new docker content disk file"
      end
      vb.customize ['createhd', '--filename', file_path, '--size', DOCKER_DISK_SIZE * 1024]
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_path]
    elsif @status == 1 #restore from backup path
      if VAGRANT_COMMAND == "up"
        puts "attach #{file_path} disk image file"
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_path]
    end
  end

  if RUBY_PLATFORM =~ /darwin/
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
  end

  config.trigger.before :destroy do
    shutdown = nil
    until ["Y", "y", "N", "n"].include?(shutdown)
        shutdown = ask "Warning! It is recommended to first run \"vagrant halt\" to stop VM then call \"vagrant destory\" if you want to backup Docker data disk;\r\nProceed to destroy VM? (Y/N) "
    end
    if shutdown.upcase == "N"
       exit
    else
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
  end

  config.omnibus.chef_version = :latest

  config.vm.provision "chef_solo" do |chef|
    if RUBY_PLATFORM =~ /darwin/
      chef.synced_folder_type = "nfs"
    end
    chef.add_recipe "firewall"
    chef.add_recipe "htop"
    chef.add_recipe "btrfs"
    if @status == 0
      chef.add_recipe "prepare_disk::new_disk"
      chef.add_recipe "prepare_disk::mount"
    elsif @status == 1
      chef.add_recipe "prepare_disk::restore_disk"
      chef.add_recipe "prepare_disk::mount"
    end
    chef.add_recipe "docker"
    chef.add_recipe "docker::compose"

    chef.json = {
      "docker" => {
        'group_members' => ['vagrant'],
        'options' => '-s btrfs --dns 8.8.8.8 --dns 8.8.4.4 -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'
      },
      "prepare_disk" => {
        'physic_dev_path' => '/dev/sdb',
        'logic_volume_group' => 'docker_btrfs',
        'logic_volume' => 'docker_btrfs01',
        'format_fs' => 'btrfs'
      }
    }
  end

end
