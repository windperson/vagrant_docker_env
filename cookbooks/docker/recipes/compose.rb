cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose" do
  path '/usr/local/bin/docker-compose'
  mode 0775
  action :create_if_missing
end
