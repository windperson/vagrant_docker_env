### Vagrant 1.8.5 bug workaround
https://github.com/mitchellh/vagrant/issues/7610

You need to manually modify the **public_key.rb** file for vagrant to successfully provision VM:

- Windows:  
    C:\HashiCorp\vagrant\embedded\gems\gems\vagrant-1.8.5\plugins\guests\linux\cap\public_key.rb
- Mac:  
    /opt/vagrant/embedded/gems/gems/vagrant-1.8.5/plugins/guests/linux/cap/public_key.rb

Add
`chmod 0600 ~/.ssh/authorized_keys`
right after line 56.

### vagrant-persistent-storage 0.0.20 quick fix
https://github.com/kusnier/vagrant-persistent-storage/pull/49/commits/4a128b1846544ccac4c2844525f3534f09ff8669

You need to maunally modify the **base.rb** file of the vagrant-persistent-storage plugin when using CentOS 7 official vagrant box.

- Windows:  
    %VAGRANT_HOME%\gems\gems\vagrant-persistent-storage-0.0.20\lib\vagrant-persistent-storage\providers\virtualbox\driver\base.rb  
    **note**: the *%VAGRANT_HOME%* environment variable is described in [offical Vagrant document](https://www.vagrantup.com/docs/other/environmental-variables.html), if it is not set, default will be `%userprofile%\.vagrant.d`.
- Mac:  
    $VAGRANT_HOME/gems/gems/vagrant-persistent-storage-0.0.20/lib/vagrant-persistent-storage/providers/virtualbox/driver/base.rb  
    **note**: the *$VAGRANT_HOME* environment variable is described in [offical Vagrant document](https://www.vagrantup.com/docs/other/environmental-variables.html), if it is not set, default will be `~/.vagrant.d`.

Modify line 28 from `if controller_name == "IDE Controller"` to `if controller_name.start_with?("IDE")`.
