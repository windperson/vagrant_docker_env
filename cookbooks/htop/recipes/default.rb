if %w{rhel}.include?(node['platform_family']) and 7 > node['platform_version'].to_i
  installer = 'epel-release-6-8.noarch.rpm'
  cookbook_file "#{Chef::Config[:file_cache_path]}/#{installer}" do
    source installer
    action :create_if_missing
  end

  rpm_package installer do
	  source "#{Chef::Config[:file_cache_path]}/#{installer}"
	  action [:install]
  end
else
  package 'epel-release' do
    action :install
  end
end

package 'htop' do
	action :install
end
