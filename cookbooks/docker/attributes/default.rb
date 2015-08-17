default['docker']['install_latest'] = true

# default will be logging on /var/lib/docker
default['docker']['logfile'] = nil

default['docker']['container_logrotate'] = true

# use string array to specify
default['docker']['group_members'] = nil

default['docker']['auto_start'] = true

default['docker']['docker-enter_src'] = 'https://raw.githubusercontent.com/jpetazzo/nsenter/master/docker-enter'
