include_recipe 'glusterfs::client_install'
include_recipe 'glusterfs::client_search_gluster'

chefstate = node[:cyclecloud][:chefstate]

chefstate = node[:cyclecloud][:chefstate] 
mounts = node['glusterfs']['mounts']
return if mounts.nil?

search_target = "Gluster Servers"

mounts.each do |name, mount|

  Chef::Log.info("Processing name,mount = #{name},#{mount}")
  if mount['hostnames'].nil?
    Chef::Log.info("hostnames not defined form glusterfs mount #{name}, ignoring.")
    return
  end

  ghosts = mount['hostnames'].dup
  ghost_prime = mount['hostnames'].sample
  ghosts.delete(ghost_prime)
  log "Randomly chose: #{ghost_prime}, from: #{mount['hostnames']}" do level :info end
  backup_nodes = ghosts.join(":")

  mount_point =  mount['mount_point'].nil? ? "/mnt/#{name}" : mount['mount_point']

  directory mount_point
  mount mount_point do
    device "#{ghost_prime}:/#{node['glusterfs']['volume']['name']}"
    fstype 'glusterfs'
    options "backup-volfile-servers=#{backup_nodes}"
    not_if "mount | grep #{mount_point}"
  end
end
