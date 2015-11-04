if %w{rhel}.include?(node['platform_family']) and 7 > node['platform_version'].to_i
  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose-old" do
    path '/usr/local/bin/docker-compose'
    mode 0775
    action :create_if_missing
  end
else
  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose" do
    path '/usr/local/bin/docker-compose'
    mode 0775
    action :create_if_missing
  end
end
