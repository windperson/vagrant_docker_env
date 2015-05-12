bash 'scan-lvm-groups' do
	code "vgscan"
end

bash 'scan-lvm-disks' do
  code "lvscan"
end

bash 'restore-lvm-disks' do
  code "lvchange -ay #{node[:'prepare_disk'][:'logic_volume_group']}/#{node[:'prepare_disk'][:'logic_volume']}"
  not_if "mount | grep #{node[:'prepare_disk'][:'logic_volume_group']}-#{node[:'prepare_disk'][:'logic_volume']}"
end
