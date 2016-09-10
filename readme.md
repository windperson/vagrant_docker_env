This vagrant project creates a **CentOS 7** / **Ubuntu 14.04 LTS** / **Ubuntu 15.10** VM and installed with:

-	docker v1.12.1
-	docker-compose v1.8.0
-	docker-machine v0.8.1

The default vagrant user can use docker command without sudo, VM stores its docker installation folder ***/var/lib/docker*** in separated disk file **disk_data/docker_data.vdi** (which is configurable via [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/index.html) in root directory), so you can backup & restore current docker image, containers and volume data even if VM is broken or upgraded.

It is a truly workable Docker environment so you can do your important project on it without fearing lost data when VM broken or recreated. :)

To start this vagrant project, you need to install

-	Oracle VirtualBox: https://www.virtualbox.org/
-	Vagrant: https://www.vagrantup.com/  
    (**note**: currently it has a issue, see [this](./vagrant_and_some_other_plugin_fix.md#vagrant-185-bug-workaround]) for workaround.)

and 4 require vagrant plugins:

-	vagrant-vbguest: https://github.com/dotless-de/vagrant-vbguest
-	vagrant-omnibus: https://github.com/chef/vagrant-omnibus
-	vagrant-triggers: https://github.com/emyl/vagrant-triggers
-	vagrant-persistent-storage: https://github.com/kusnier/vagrant-persistent-storage  
    (**note**: currently it has a issue when using official CentOS 7 vagrant box, see [this](./vagrant_and_some_other_plugin_fix.md#vagrant-persistent-storage-0020-quick-fix]) for workaround.)

### CentOS 7

It use [official CentOS 7 vagrant box](https://vagrantcloud.com/centos/boxes/7) (When specified vagrant box is **centos/7**)to "*power on*", which is made from [those script](https://github.com/CentOS/sig-cloud-instance-build/tree/master/vagrant), and host mapping inside VM of this Vagrant project folder is **/vagrant**, the same as default vagrant configuration.

### Ubuntu 14.04 LTS & Ubuntu 15.10

It use [official Ubuntu Server 14.04 LTS (Trusty Tahr) vagrant box](https://vagrantcloud.com/ubuntu/boxes/trusty64) (When specified vagrant box is **ubuntu/trusty64**) or [official Ubuntu Server 15.10 Wily Werewolf (development) builds](https://vagrantcloud.com/ubuntu/boxes/wily64) (When specified vagrant box is **ubuntu/wily64**) to "*power on*", and host mapping inside VM of this Vagrant project folder is **/vagrant**, the same as default vagrant configuration.

**Note:** You may need to modify booted setting then reboot the VM for doing heavy loading affairs, since the [vagrant chef solo provisioner](https://www.vagrantup.com/docs/provisioning/chef_solo.html) incapable to do VM restart, so it must be done manually, then use "[vagrant reload](https://www.vagrantup.com/docs/cli/reload.html)" command on host to reboot the VM, see official docker installation document to know how to do it: https://docs.docker.com/engine/installation/linux/ubuntulinux/#adjust-memory-and-swap-accounting

You can tweak:

-	The separated docker data disk file size, use [LVM](https://en.wikipedia.org/wiki/Logical_Volume_Manager_%28Linux%29) to mount data disk or not, VM CPU core(s), RAM size in Vagrantfile line 11~16.
- VM name appear in VirtualBox GUI manager and vagrant up process in Vagrantfile line 17.
- VM hostname that will show in bash prompt and recorded in */etc/hostname* inside VM in Vagrantfile line 18.
- Vagrant box that will be used to create VM in Vagrantfile line 19.
-	VM private IP address in Vagrantfile line 20. (Default I left it as "*dhcp*" for better various environment compatibility, you can use [vagrant-address](https://github.com/mkuzmin/vagrant-address) plugin to find started VM private network IP address.)
-	Docker Engine startup parameter in Vagrantfile line 21 for enable insecure registry or private repos as mentioned in [offical document](https://docs.docker.com/registry/insecure/).
