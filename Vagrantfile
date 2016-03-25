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
VM_IP = '192.168.103.101'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox"
  config.vm.provider "parallels"
  config.vm.provider "vmware_fusion"

  config.vm.box = "#{VG_BOX_NAME}"
  config.ssh.insert_key = false
  config.vm.hostname = 'dockerhost'
  config.vm.define "dockerhost"
  config.vm.network :private_network, :ip => "#{VM_IP}"
  file_disk = "docker_data.vdi"
  attach_dir = "disk_data"
  file_path = Pathname.new(attach_dir).join(file_disk)
  file_disk_size = DOCKER_DISK_SIZE * 1024 #storage unit: MB
  FLAG_FILE = ".vagrant/.created"

  def setup_and_enable_vg_persistent(config, file_path, file_disk_size)
    config.persistent_storage.enabled = true
    config.persistent_storage.location = "#{file_path}"
    config.persistent_storage.size = file_disk_size
    config.persistent_storage.mountname = 'dockerdata'
    config.persistent_storage.filesystem = 'btrfs'
    config.persistent_storage.mountpoint = '/var/lib/docker'
  end

  if VAGRANT_COMMAND == "up" and not File.exist?(FLAG_FILE)
    setup_and_enable_vg_persistent(config, file_path, file_disk_size)
    File.open(FLAG_FILE, "w+") do |f|
      f.write("docker data disk of #{config.vm.hostname} has been created at #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}")
    end
  end

  if VAGRANT_COMMAND == "destroy"
    setup_and_enable_vg_persistent(config, file_path, file_disk_size)
  end

  config.trigger.after :destroy do
    if File.exist?(FLAG_FILE)
      File.delete(FLAG_FILE)
    end
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", "#{VM_RAM_SIZE}"]
    vb.customize ["modifyvm", :id, "--cpus", "#{VM_CPU_CORE}"]
  end

  config.omnibus.chef_version = :latest

  config.vm.provision "chef_solo" do |chef|
    chef.add_recipe "firewall"
    chef.add_recipe "htop"

    chef.add_recipe "docker"
    chef.add_recipe "docker::compose"
    chef.add_recipe "docker::machine"

    chef.json = {
      "docker" => {
        'group_members' => ['vagrant'],
        'options' => '-s btrfs --dns 8.8.8.8 --dns 8.8.4.4 -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'
      }
    }
  end

end
