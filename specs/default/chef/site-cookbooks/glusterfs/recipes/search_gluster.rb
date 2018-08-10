chefstate = node[:cyclecloud][:chefstate] 

if node['glusterfs'][:hostname].nil?
  cluster_UID = node['glusterfs']['clusterUID']
  if cluster_UID.nil?
    cluster_UID = node[:cyclecloud][:cluster][:id]
  end

  node_role = node['glusterfs']['role']
  if !node_role.nil?
    log "Searching for the dnsmasq namserver in cluster: #{cluster_UID}, role: #{node_role}" do level :info end
    cluster_nodes = cluster.search(:clusterUID => cluster_UID, :role => node_role)
  else
    node_recipe = node['glusterfs']['recipe']
    if !node_recipe.nil?
      log "Searching for gluster servers in cluster: #{cluster_UID}, recipe: #{node_recipe}" do level :info end
      cluster_nodes = cluster.search(:clusterUID => cluster_UID, :recipe => node_recipe)
    else
      log "Must specify node['glusterfs']['role'] or node['glusterfs']['recipe'] for search." do level :error end
    end
  end

  raise "No master nodes found." if cluster_nodes.length == 0

  #node.default['glusterfs']['target_count'] = 4
  node.default['glusterfs']['live_count'] = cluster_nodes.length

  #cluster_nodes_sorted = cluster_nodes.sort_by{ |x| x['hostname'] }
  cluster_nodes_sorted = cluster_nodes.sort_by{ |x| get_hostname(x['ipaddress']) }

  Chef::Log.info("Found Master Hostnames = #{ cluster_nodes_sorted.map{|x| x['hostname']}}")
  Chef::Log.info("Found Master Hostnames = #{ cluster_nodes_sorted.map{|x| get_hostname(x['ipaddress'])}}")
  #node.default['glusterfs']['hostnames'] = cluster_nodes_sorted.map{|x| x['hostname']}
  node.default['glusterfs']['reverse_hostnames'] = cluster_nodes_sorted.map{|x| get_hostname(x['ipaddress'])}
  node.default['glusterfs']['hostnames'] = cluster_nodes_sorted.map{|x| x['hostname']}
  node.default['glusterfs']['fqdns'] = cluster_nodes_sorted.map{|x| x['fqdn']}
  
  Chef::Log.info("Found Master IPs = #{ cluster_nodes_sorted.map{|x| x['ipaddress']}}")
  node.default['glusterfs']['ip_addresses'] =  cluster_nodes_sorted.map{|x| x['ipaddress']}

end