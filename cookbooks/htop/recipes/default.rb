installer = 'epel-release-6-8.noarch.rpm'
cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
  source installer
  action :create_if_missing
end

rpm_package installer do
	source "#{Chef::Config[:file_cache_path]}/#{installer}"
	action [:install]
end

package 'htop' do
	action :install
end