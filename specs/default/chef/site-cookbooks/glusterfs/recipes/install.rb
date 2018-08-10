

bootstrap = node['cyclecloud']['bootstrap']

execute 'rhel subscription' do
  command "subscription-manager register --username=#{node['rhel']['subscription']['username']} --password=#{node['rhel']['subscription']['password']} || subscription-manager register --activationkey=#{node['rhel']['subscription']['activation_key']} --org=#{node['rhel']['subscription']['org']} && touch #{bootstrap}/rhel-subscription.done"
  not_if { ::File.exist?("#{bootstrap}/rhel-subscription.done") }
  only_if { node['platform'] == "redhat" }
end 

package 'centos-release-gluster' do
  only_if { node['platform'] == 'centos' }
end

%w(glusterfs-cli glusterfs-geo-replication glusterfs-fuse glusterfs-server glusterfs ).each do |pkg|
  package pkg
end

systemd_unit 'glusterd.service' do
  action [:enable, :start]
end

bash "gluster reset uuid" do
  code <<-EOH
  yes | gluster system:: uuid reset
  touch #{bootstrap}/gluster.reset.uuid
EOH
  not_if { ::File.exist?("#{bootstrap}/gluster.reset.uuid") }
end

systemd_unit 'glusterfsd.service' do
  action [:enable, :start]
  only_if { node['platform'] == 'centos' }
end