IsCentOS7orAbove = %w{rhel}.include?(node['platform_family']) and 7 >= node['platform_version'].to_i

if not IsCentOS7orAbove
  use_bundle_installer = true
  installer = 'docker-io-1.7.1-2.el6.x86_64.rpm'
elsif %w{rhel}.include?(node['platform_family'])
  use_bundle_installer = false
end

package ['device-mapper', 'device-mapper-event-libs'] do
  action :upgrade
end

if use_bundle_installer
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
    source installer
    action :create_if_missing
  end
  yum_package "install-docker" do
    source "#{Chef::Config[:file_cache_path]}/#{installer}"
    action [:install]
  end
else
  template '/etc/yum.repos.d/docker.repo' do
    source 'docker.repo.erb'
    owner 'root'
    group 'root'
    mode 00547
  end
  yum_package "docker-engine" do
    flush_cache [ :before ]
    action [:install]
  end
end

template "#{node[:docker][:centos7_systemd_config]}"  do
  source 'docker.systemd.erb'
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
		:DockerOther_args => node[:docker][:options],
    :DockerLogfile => node[:docker][:logfile]
		})
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

bash 'add-firewall-rule' do
	code 'iptables -I INPUT 4 -i docker0 -j ACCEPT'
	only_if 'iptables -S INPUT | grep "docker0 -j ACCEPT"' and %w{rhel}.include?(node['platform_family']) and 7 > node['platform_version'].to_i
end

bash 'add-firewall-rule for CentOS 7' do
  code 'firewall-cmd --permanent --zone=trusted --add-interface=docker0 && firewall-cmd --permanent --zone=trusted --add-port=4243/tcp && firewall-cmd --reload'
  only_if 'firewall-cmd --state | grep "^running$"' and IsCentOS7orAbove
end
