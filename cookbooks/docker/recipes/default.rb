installer = 'epel-release-6-8.noarch.rpm'
cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
  source installer
  action :create_if_missing
end

rpm_package installer do
	source "#{Chef::Config[:file_cache_path]}/#{installer}"
	action [:install]
end

package ['device-mapper', 'device-mapper-event-libs'] do
  action :upgrade
end

package "install-docker-official-binary" do
  package_name 'docker-io'
	action :install
  options "--enablerepo=epel-testing"
  flush_cache [:before]
  only_if {node[:docker][:get_official_binary]}
end

package 'install-docker-yum-version' do
  package_name 'docker-io'
	action :install
  allow_downgrade true
  flush_cache [:before]
  version "#{node[:'docker'][:'version']}"
  not_if {node[:docker][:get_official_binary]}
end

remote_file "/usr/bin/docker" do
  source node['docker']['official_binary_url']
  mode 00775
  only_if {node[:docker][:get_official_binary]}
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
	only_if 'iptables -S INPUT | grep "docker0 -j ACCEPT"'
end
