include_recipe 'glusterfs::install'
include_recipe 'glusterfs::config_gluster'
include_recipe 'glusterfs::search_gluster'

bootstrap = node['cyclecloud']['bootstrap']


vol_name = node['glusterfs']['volume']['name']
vol_type = node['glusterfs']['volume']['type']
arg1 = ''
arg2 = ''

if vol_type == "replica"
  raise "Volume type replica, but odd number of nodes used. " if node['glusterfs']['target_count']%2 == 1
  arg1 = 'replica'
  arg2 = '2'
elsif vol_type ==  "stripe"
  arg1 = 'strip'
  arg2 = "#{node['glusterfs']['target_count']}"
else
  arg1 = ''
  arg2 = ''
end

Chef::Log.info("Do we have quorum live_count=#{node['glusterfs']['live_count']}, target_count=#{node['glusterfs']['target_count']}")
raise "No glusterfs quorum. Live Count = #{node['glusterfs']['live_count']}, Target Count = #{node['glusterfs']['target_count']}" if node['glusterfs']['live_count'] != node['glusterfs']['target_count']

ruby_block 'host_not_ready' do
  block do
    raise "Hostnames not ready: #{node['glusterfs']['reverse_hostnames']} != #{node['glusterfs']['hostnames']}"
  end
  only_if { node['cyclecloud']['hosts']['standalone_dns']['enabled'] }
  only_if { node['glusterfs']['reverse_hostnames'] != node['glusterfs']['hostnames'] }
end

Chef::Log.info("Checking last: #{node['hostname'].downcase} != #{node['glusterfs']['hostnames'].last}")
return if node['hostname'].downcase != node['glusterfs']['hostnames'].last.downcase

jetpack_log "Organizing gluster node: #{node['hostname']}, #{node['azure']['metadata']['compute']['name']}" do
  level "info"
end

if node['platform'] == "redhat"
  ghosts = node['glusterfs']['fqdns'].dup
else
  ghosts = node['glusterfs']['hostnames'].dup
end

Chef::Log.info("Full server list = #{ghosts}")
drop = ghosts.pop
Chef::Log.info("Peer servers = #{ghosts}")

if node['platform'] == "redhat"
  all_ghosts = "#{node['fqdn']}:#{node['glusterfs']['drive']}"
else
  all_ghosts = "#{node['hostname']}:#{node['glusterfs']['drive']}"
end
Chef::Log.info("all_ghosts = #{ghosts}")
ghosts.each do |ghost|
  all_ghosts << " #{ghost}:#{node['glusterfs']['drive']}"
  Chef::Log.info("all_ghosts = #{ghosts}")
  bash "gluster peer with #{ghost}" do
    code <<-EOH
ping -c 3 #{ghost} > /tmp/error
gluster peer probe #{ghost} >> /tmp/error
EOH
    not_if "gluster peer status | grep #{ghost}"
    retries 10
    retry_delay 2
  end
end

execute 'create_gluster_volume' do
  command "yes | gluster volume create #{vol_name} #{arg1} #{arg2} transport tcp #{all_ghosts} force 2>> /tmp/glusterfs_error "
  not_if "gluster volume info #{node['glusterfs']['volume']['name']}"
end

bash "configure_gluster_cluster" do
code <<-EOH
gluster volume info 2>> /tmp/error
gluster volume start #{vol_name} 2>> /tmp/error

#Tune for small file improvements
gluster volume set #{vol_name} features.cache-invalidation on
gluster volume set #{vol_name} features.cache-invalidation-timeout 600
gluster volume set #{vol_name} performance.stat-prefetch on
gluster volume set #{vol_name} performance.cache-samba-metadata on
gluster volume set #{vol_name} performance.cache-invalidation on
gluster volume set #{vol_name} performance.md-cache-timeout 600
gluster volume set #{vol_name} network.inode-lru-limit 90000
touch #{bootstrap}/gluster.volume.configured
EOH
not_if { ::File.exist?("#{bootstrap}/gluster.volume.configured") }
end
  