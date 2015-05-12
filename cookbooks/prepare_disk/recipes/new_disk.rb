require 'pathname'

dev_name = Pathname.new("#{node[:'prepare_disk'][:'physic_dev_path']}").basename.to_s

bash 'fdisk' do
	code "echo -e \"o\nn\np\n1\n\n\nw\" | fdisk -c #{node[:'prepare_disk'][:'physic_dev_path']}"
  not_if "lsblk -l | grep part | grep #{dev_name}"
end

bash 'initialize-physical-partition' do
  code "pvcreate #{node[:'prepare_disk'][:'physic_dev_path']}1"
end

bash 'create-lvm-group' do
  code "vgcreate #{node[:'prepare_disk'][:'logic_volume_group']} #{node[:'prepare_disk'][:'physic_dev_path']}1"
  not_if "vgscan | grep #{node[:'prepare_disk'][:'logic_volume_group']}"
end

bash 'create-lvm-volume' do
  code "lvcreate -l 100%FREE -n #{node[:'prepare_disk'][:'logic_volume']} #{node[:'prepare_disk'][:'logic_volume_group']}"
end

bash 'format-partition' do
  code "mkfs.#{node[:'prepare_disk'][:'format_fs']} /dev/#{node[:'prepare_disk'][:'logic_volume_group']}/#{node[:'prepare_disk'][:'logic_volume']}"
  not_if "mount | grep #{node[:'prepare_disk'][:'logic_volume_group']}-#{node[:'prepare_disk'][:'logic_volume']}"
end
