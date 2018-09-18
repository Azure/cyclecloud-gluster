

bootstrap = node['cyclecloud']['bootstrap']

include_recipe '::_rhel_subscription' if node['platform'] == "redhat"
include_recipe '::_install_rhel' if node['platform'] == "redhat"

package 'centos-release-gluster' do
  only_if { node['platform'] == 'centos' }
end

%w(glusterfs-cli glusterfs-geo-replication glusterfs-fuse glusterfs-server glusterfs ).each do |pkg|
  package pkg do
    only_if { node['platform'] == 'centos' }
  end
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
  only_if { node['platform'] == 'centos' }
end

systemd_unit 'glusterfsd.service' do
  action [:enable, :start]
  only_if { node['platform'] == 'centos' }
end