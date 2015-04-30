# 1. Create "/etc/yum.repos.d/rsyslog.repo" file
template node['selinux']['config'] do
	source 'config.erb'
	owner 'root'
	group 'root'
	mode 00644
end
