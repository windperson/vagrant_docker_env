package 'btrfs-progs' do
	action :install
end

bash "modprobe btrfs" do
  not_if "lsmod | grep btrfs"
end
