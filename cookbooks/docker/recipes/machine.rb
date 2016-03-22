cookbook_file "#{Chef::Config[:file_cache_path]}/docker-machine.latest.binary" do
  path '/usr/local/bin/docker-machine'
  mode 0775
  action :create
end
