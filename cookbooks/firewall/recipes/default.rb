if %w{rhel}.include?(node['platform_family']) and 7 <= node['platform_version'].to_i
  service 'firewalld' do
    action [:disable, :stop]
  end
end
if %w{rhel}.include?(node['platform_family'])
  service 'iptables' do
      action [:disable, :stop]
  end

  service 'ip6tables' do
      action [:disable, :stop]
  end
end
