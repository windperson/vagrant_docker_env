# default will be logging on /var/lib/docker
default['docker']['logfile'] = nil

default['docker']['container_logrotate'] = true

# use string array to specify
default['docker']['group_members'] = nil

default['docker']['auto_start'] = true

default['docker']['systemd_config'] = '/etc/systemd/system/docker.service.d'
