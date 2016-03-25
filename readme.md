This vagrant project contains a CentOS 7 VM and installed with:

-	docker v1.10.3
-	docker-compose v1.6.2
-	docker-machine v0.6.0

To start this vagrant project, you need to install

-	Oracle VirtualBox: https://www.virtualbox.org/
-	Vagrant: https://www.vagrantup.com/

and 4 require vagrant plugins:

-	vagrant-vbguest: https://github.com/dotless-de/vagrant-vbguest
-	vagrant-omnibus: https://github.com/chef/vagrant-omnibus
-	vagrant-triggers: https://github.com/emyl/vagrant-triggers
-	vagrant-persistent-storage: https://github.com/kusnier/vagrant-persistent-storage

The successfully initiated VM store its docker installation folder /var/lib/docker in separated disk file *disk_data/docker_data.vdi* , so you can backup & restore current docker image, containers and volume data even if VM deleted then recreated.

You can tweak:

-	VM CPU core(s), RAM size, the separated docker data disk file size from Vagrantfile line 11~15.
-	Docker Engine startup parameter in Vagrantfile line 16 for enable insecure registry or private repos as mentioned in [offical document](https://docs.docker.com/registry/insecure/).
