if %w{rhel}.include?(node['platform_family']) and 7 > node['platform_version'].to_i
  installer = 'docker-engine-1.7.0-1.el6.x86_64.rpm'
  #docker_package_name = 'docker-io'
elsif %w{rhel}.include?(node['platform_family'])
  installer = 'docker-engine-1.7.0-1.el7.centos.x86_64.rpm'
  #docker_package_name = 'docker'
end

package ['device-mapper', 'device-mapper-event-libs'] do
  action :upgrade
end

cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
  source installer
  action :create_if_missing
end

yum_package "install-docker" do
  source "#{Chef::Config[:file_cache_path]}/#{installer}"
  action [:install]
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

service 'docker' do
    action [:disable, :stop]
    not_if {node[:docker][:auto_start]}
end

service 'docker' do
    action [:enable, :start]
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
