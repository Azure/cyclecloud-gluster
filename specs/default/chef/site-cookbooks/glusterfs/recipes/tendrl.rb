include_recipe '::selinux'
include_recipe '::_rhel_subscription'

bootstrap = node['cyclecloud']['bootstrap']

bash 'rhel_tendrl_firewall' do
  code <<-EOF
  firewall-cmd --permanent --zone=public --add-port=2379/tcp
  firewall-cmd --permanent --zone=public --add-port=2003/tcp
  firewall-cmd --permanent --zone=public --add-port=10080/tcp
  firewall-cmd --permanent --zone=public --add-service=http
  firewall-cmd --permanent --zone=public --add-port=9292/tcp
  firewall-cmd --permanent --zone=public --add-port=3000/tcp
  firewall-cmd --permanent --zone=public --add-port=8789/tcp   
  firewall-cmd --reload && touch #{bootstrap}/rhel_tendrl_firewall.done
  EOF
  not_if { ::File.exist?("#{bootstrap}/rhel_tendrl_firewall.done") }
end


bash 'rhel_tendrl_repo_config' do
  code <<-EOH
  rm -f /etc/machine-id
  systemd-machine-id-setup
  firewall-cmd --permanent --zone=public --add-port=8697/tcp
  firewall-cmd --reload && touch #{bootstrap}/rhel_tendrl_repo_config.done
  EOH
  not_if { ::File.exist?("#{bootstrap}/rhel_tendrl_repo_config.done") }
end

include_recipe '::search_gluster'

Chef::Log.info("Do we have quorum live_count=#{node['glusterfs']['live_count']}, target_count=#{node['glusterfs']['target_count']}")
raise "No glusterfs quorum. Live Count = #{node['glusterfs']['live_count']}, Target Count = #{node['glusterfs']['target_count']}" if node['glusterfs']['live_count'] != node['glusterfs']['target_count']

ruby_block 'host_not_ready' do
  block do
    raise "Hostnames not ready: #{node['glusterfs']['reverse_hostnames']} != #{node['glusterfs']['hostnames']}"
  end
  only_if { node['cyclecloud']['hosts']['standalone_dns']['enabled'] }
  only_if { node['glusterfs']['reverse_hostnames'] != node['glusterfs']['hostnames'] }
end

admin_user = node['cyclecloud']['cluster']['user']['name']
admin_home = "#{node['cuser']['base_home_dir']}/#{admin_user}"

template "#{admin_home}/inventory" do
  source "inventory.erb"
  owner admin_user
  group admin_user
  variables(:user => admin_user, :home_dir => admin_home)
end

link "#{admin_home}/site.yml" do
  to '/usr/share/doc/tendrl-ansible-1.6.3/site.yml'
end

cookbook_file '/etc/ansible/ansible.cfg' do
  source 'ansible.cfg'
  mode '0755'
  action :create
end

execute 'run_ansible_playbook' do
  command 'ansible-playbook -b -i inventory site.yml'
  user admin_user
  cwd admin_home
  environment ({
    'HOME' => admin_home,
    'USER' => admin_user
  })
  timeout 1800
end