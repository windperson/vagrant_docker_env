package 'bash-completion' do
	action :install
end

if %w{rhel}.include?(node['platform_family']) and 7 > node['platform_version'].to_i
  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose.152.binary" do
    path '/usr/local/bin/docker-compose'
    mode 0775
    action :create
  end

  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose.152.bash-completion" do
    path '/etc/bash_completion.d/docker-compose'
    mode 0644
    action :create
  end

else
  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose.latest.binary" do
    path '/usr/local/bin/docker-compose'
    mode 0775
    action :create
  end

  cookbook_file "#{Chef::Config[:file_cache_path]}/docker-compose.latest.bash-completion" do
    path '/etc/bash_completion.d/docker-compose'
    mode 0644
    action :create
  end

end
