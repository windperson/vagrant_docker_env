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

yum_package 'docker-io' do
	action :install
  version "#{node[:'docker'][:'version']}"
  options "--enablerepo=epel-testing"
  flush_cache [:before]
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

group 'docker' do
  members node[:'docker'][:'group_members']
  append true
  not_if {node[:'docker'][:'group_members'] == nil}
end
