package 'btrfs-progs' do
	action :install
end

bash 'add-kernel-module-loading' do
	code 'echo modprobe btrfs >> /etc/rc.modules && chmod +x /etc/rc.modules'
  not_if "lsmod | grep btrfs"
end

bash 'load-kernel-module' do
	code 'modprobe btrfs'
	not_if "lsmod | grep btrfs"
end
