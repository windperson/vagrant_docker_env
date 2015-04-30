# 0. install epel repository
installer = 'epel-release-6-8.noarch.rpm'
cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
  source installer
end

rpm_package installer do
	source "#{Chef::Config[:file_cache_path]}/#{installer}"
	action [:install]
end

yum_package "docker-io" do
	options "--enablerepo=epel-testing"
	flush_cache [ :before ] # it is necessary to flush cache after add repository config.
	action :install
end

template node['docker']['config'] do
	source 'sysconfig_docker.erb'
	owner 'root'
	group 'root'
	mode 00644
end

template node['docker-storage']['config'] do
	source 'sysconfig_docker-storage.erb'
	owner 'root'
	group 'root'
	mode 00644
end

if defined?(node[:docker][:grant_users])
	group "docker" do
		action :modify
		members node[:docker][:grant_users]
		append true
	end
end

service 'docker' do
    action [:enable, :start]
end