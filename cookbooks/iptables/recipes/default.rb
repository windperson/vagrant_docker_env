service 'iptables' do
    action [:disable, :stop]
end

service 'ip6tables' do
    action [:disable, :stop]
end