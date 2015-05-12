bash 'add-permanent-mount-setting' do
	code "echo \"/dev/#{node[:'prepare_disk'][:'logic_volume_group']}/#{node[:'prepare_disk'][:'logic_volume']} /var/lib/docker #{node[:'prepare_disk'][:'format_fs']} defaults 0 0\" >> /etc/fstab"
  not_if "cat /etc/fstab | grep #{node[:'prepare_disk'][:'logic_volume_group']}/#{node[:'prepare_disk'][:'logic_volume']}"
end

bash 'mount' do
	code 'mount -a'
end
