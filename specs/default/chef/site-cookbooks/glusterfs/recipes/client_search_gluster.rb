chefstate = node[:cyclecloud][:chefstate] 
mounts = node['glusterfs']['mounts']
return if mounts.nil?

search_target = "Gluster Servers"

mounts.each do |name, mount|
  Chef::Log.info("Processing name,mount = #{name},#{mount}")
  mount = node['glusterfs']['default_mount'].merge(mount)
  Chef::Log.info("Processing post merge name,mount = #{name},#{mount}")
  if mount['hostnames'].nil?
    cluster_UID = mount['clusterUID']
    if cluster_UID.nil?
      Chef::Log.info("hostnames and clusterUID undefined for #{name}, not mounting.")
      return
      #cluster_UID = node[:cyclecloud][:cluster][:id]
    end

    node_role = mount['role']
    if !node_role.nil?
      log "Searching for #{search_target} in cluster: #{cluster_UID}, role: #{node_role}" do level :info end
      cluster_nodes = cluster.search(:clusterUID => cluster_UID, :role => node_role)
    else
      node_recipe = mount['recipe']
      if !node_recipe.nil?
        log "Searching for #{search_target} in cluster: #{cluster_UID}, recipe: #{node_recipe}" do level :info end
        cluster_nodes = cluster.search(:clusterUID => cluster_UID, :recipe => node_recipe)
      else
        log "Must specify gluster.fs.mounts.#{name}.role or gluster.fs.mounts.#{name}.recipe for search." do level :error end
      end
    end

    raise "No #{search_target} nodes found. For #{name}, #{mount}, #{cluster_UID}" if cluster_nodes.length == 0

    #node.default['glusterfs']['target_count'] = 4
    mount['live_count'] = cluster_nodes.length

    cluster_nodes_sorted = cluster_nodes.sort_by{ |x| get_hostname(x['ipaddress']) }

    Chef::Log.info("Found #{search_target} #{name} Hostnames = #{ cluster_nodes_sorted.map{|x| x['hostname']}}")
    Chef::Log.info("Found #{search_target} #{name} Hostnames = #{ cluster_nodes_sorted.map{|x| get_hostname(x['ipaddress'])}}")
    Chef::Log.info("Found #{search_target} #{name} IPs = #{ cluster_nodes_sorted.map{|x| x['ipaddress']}}")

    node.default['glusterfs']['mounts'][name]['hostnames'] = cluster_nodes_sorted.map{|x| x['hostname']}
    node.default['glusterfs']['mounts'][name]['ipaddresses'] = cluster_nodes_sorted.map{|x| x['ipaddress']}

  end
end
