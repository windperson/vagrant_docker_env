OS_name=node['platform']
OS_family=node['platform_family']
OS_ver=node['platform_version'].to_f
log 'print OS info' do
  message "OS_name=#{OS_name}, OS_family=#{OS_family} ver=#{OS_ver}"
  level :info
end

IsCentOS7orAbove = ( %w{centos}.include?(OS_name) and %w{rhel}.include?(OS_family) and 7 <= OS_ver )
IsCentOS6 = ( %w{centos}.include?(OS_name) and  %w{rhel}.include?(OS_family) and 7 > OS_ver )
IsUbuntu = ( %w{ubuntu}.include?(OS_name) and %w{debian}.include?(OS_family) )

use_bundle_installer = false
if IsCentOS6
  use_bundle_installer = true
  installer = 'docker-io-1.7.1-2.el6.x86_64.rpm'
  log 'using bundle installer' do
    level :info
  end
elsif IsCentOS7orAbove or IsUbuntu
  use_bundle_installer = false
  log 'install from official source' do
    level :info
  end
end

package ['device-mapper', 'device-mapper-event-libs'] do
  action :upgrade
  only_if { (IsCentOS6 or IsCentOS7orAbove) }
end

if use_bundle_installer
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
    source installer
    action :create_if_missing
  end
  yum_package "install-docker" do
    source "#{Chef::Config[:file_cache_path]}/#{installer}"
    action [:install, :upgrade]
  end
elsif IsCentOS7orAbove
  template '/etc/yum.repos.d/docker.repo' do
    source 'docker.repo.centos.erb'
    owner 'root'
    group 'root'
    mode 00547
  end

  package 'deltarpm' do
  	action [:install, :upgrade]
  end

  yum_package "docker-engine" do
    flush_cache [ :before ]
    action [:install, :upgrade]
  end
elsif IsUbuntu
  package ['apt-transport-https', 'ca-certificates'] do
    action :install
  end

  bash 'add-GPG-key-for-Ubuntu' do
    code 'DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
  end

  template '/etc/apt/sources.list.d/docker.list' do
    source 'docker.list.ubuntu.erb'
    owner 'root'
    group 'root'
    mode 00744
    variables({
      :os_ver => node['platform_version'].to_f
      })
    action :create
  end

  bash 'update-apt-repo-and-install-extra-stuff' do
    code 'DEBIAN_FRONTEND=noninteractive apt-get update '\
         '&& apt-get purge -y lxc-docker '\
         '&& apt-get install -y linux-image-extra-$(uname -r) '\
         '&& apt-get autoremove -y'
  end

  bash 'install:linux-image-extra' do
    code 'DEBIAN_FRONTEND=noninteractive '
  end

  package "docker-engine" do
    action [:install]
  end

end

service 'docker' do
    action [:stop]
end

directory "#{node[:docker][:centos7_systemd_config]}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  only_if { IsCentOS7orAbove }
end

template "#{node[:docker][:centos7_systemd_config]}/docker.conf"  do
  source 'docker.conf.erb'
  owner 'root'
  group 'root'
  mode 00547
  only_if { IsCentOS7orAbove }
end

template '/etc/sysconfig/docker' do
	source 'docker.erb'
	owner 'root'
	group 'root'
	mode 00547
	variables({
		:DockerOption_args => node[:docker][:options],
    :DockerLogfile => node[:docker][:logfile]
		})
  only_if { IsCentOS7orAbove }
end

template '/etc/default/docker' do
	source 'docker.erb'
	owner 'root'
	group 'root'
	mode 00547
	variables({
		:DockerOption_args => node[:docker][:options],
    :DockerLogfile => node[:docker][:logfile]
		})
  only_if { IsUbuntu and OS_ver < 15 }
end


bash 'systemd-reload-config' do
  code "systemctl daemon-reload"
	only_if { IsCentOS7orAbove }
end

service 'docker' do
    action [:reload]
end

service 'docker' do
    action [:disable, :stop]
    not_if {node[:docker][:auto_start]}
end

service 'docker' do
    action [:enable, :stop, :restart]
    only_if {node[:docker][:auto_start]}
end

template '/etc/logrotate.d/docker-container' do
	source 'docker-container-logrotate.erb'
	owner 'root'
	group 'root'
	mode 00644
  only_if {node[:docker][:container_logrotate]}
end

group 'docker' do
  members node[:'docker'][:'group_members']
  append true
  not_if {node[:'docker'][:'group_members'] == nil}
end

if IsCentOS7orAbove
  bash 'add-firewall-rule' do
	   code 'iptables -I INPUT 4 -i docker0 -j ACCEPT'
	   only_if 'iptables -S INPUT | grep "docker0 -j ACCEPT"'
  end

  bash 'add-firewall-rule for CentOS 7' do
    code 'firewall-cmd --permanent --zone=trusted --add-interface=docker0 && firewall-cmd --permanent --zone=trusted --add-port=4243/tcp && firewall-cmd --reload'
    only_if 'firewall-cmd --state | grep "^running$"'
  end
end

if IsUbuntu

  template '/etc/default/ufw' do
  	source 'ubuntu.ufw.erb'
  	owner 'root'
  	group 'root'
  	mode 00644
    only_if "which ufw"
  end

  bash 'reload-ubuntu-UFW' do
    code 'ufw reload && ufw allow 2375/tcp && ufw allow 2376/tcp'
    only_if "which ufw"
  end
end
