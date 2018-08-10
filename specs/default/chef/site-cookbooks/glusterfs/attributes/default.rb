default['glusterfs']['drive'] = '/datadrive/brick'
default['glusterfs']['volume']['type'] = 'replca'
default['glusterfs']['volume']['level'] = 2
default['glusterfs']['volume']['name'] = 'gfsvol'
default['glusterfs']['volume']['test']['deadline'] = 10
default['glusterfs']['target_count'] = 4
default['glusterfs']['live_count'] = 0

default['glusterfs']['mount_point'] = '/mnt/gluster'

# search 
default['glusterfs']['default_mount']['mount_point'] = nil
default['glusterfs']['default_mount']['hostnames'] = nil
default['glusterfs']['default_mount']['reverse_hostnames'] = nil
default['glusterfs']['default_mount']['role'] = nil
default['glusterfs']['default_mount']['clusterUID'] = nil
default['glusterfs']['default_mount']['recipe'] = "glusterfs::server"
default['glusterfs']['default_mount']['ip_addresses'] = nil
default['glusterfs']['default_mount']['fqdns'] = nil
default['glusterfs']['default_mount']['live_count'] = 0

# search master
default['glusterfs']['clusterUID'] = nil
default['glusterfs']['hostnames'] = nil
default['glusterfs']['reverse_hostnames'] = nil
default['glusterfs']['role'] = nil
default['glusterfs']['recipe'] = "glusterfs::server"
default['glusterfs']['ip_addresses'] = nil
default['glusterfs']['fqdn'] = nil

# RHEL subscription
default['rhel']['subscription']['username'] = nil
default['rhel']['subscription']['password'] = nil
default['rhel']['subscription']['activation_key'] = nil 
default['rhel']['subscription']['org'] = nil
