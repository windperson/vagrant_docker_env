default['docker']['version'] = '1.5.0-1.el6'

# default will be logging on /var/lib/docker
default['docker']['logfile'] = nil

# use string array to specify
default['docker']['group_members'] = nil

default['docker']['auto_start'] = true

default['docker']['get_official_binary'] = false
default['docker']['official_binary_url'] = 'https://get.docker.com/builds/Linux/x86_64/docker-latest'
