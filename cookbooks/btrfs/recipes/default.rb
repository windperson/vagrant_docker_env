package 'btrfs-progs' do
	action :install
end

bash 'add-kernel-module-loading-01' do
	code 'echo modprobe btrfs >> /etc/rc.modules'
  not_if "lsmod | grep btrfs"
end

bash 'add-kernel-module-loading-02' do
	code 'chmod +x /etc/rc.modules'
  not_if "test -x /etc/rc.modules"
end

bash 'load-kernel-module' do
	code 'modprobe btrfs'
	not_if "lsmod | grep btrfs"
end
