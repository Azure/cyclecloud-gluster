
bootstrap = node['cyclecloud']['bootstrap']

package 'psmisc'

gluster_version='4.1.1'
gluster_platform=node['platform_version'].to_i.to_s


bash "install-glusterfs-libs" do
    code <<-EOH
  wget --no-cache https://buildlogs.centos.org/centos/#{gluster_platform}/storage/x86_64/gluster-4.1/glusterfs-libs-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
  rpm -i glusterfs-libs-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
  EOH
  not_if 'rpm -qa | grep glusterfs-libs'
end

bash "install-glusterfs" do
  code <<-EOH
  wget --no-cache https://buildlogs.centos.org/centos/#{gluster_platform}/storage/x86_64/gluster-4.1/glusterfs-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
  rpm -i glusterfs-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
touch #{bootstrap}/glusterfs.installed
EOH
creates #{bootstrap}/glusterfs.installed
end

bash "install-glusterfs-client-xlators" do
  code <<-EOH
  wget https://buildlogs.centos.org/centos/#{gluster_platform}/storage/x86_64/gluster-4.1/glusterfs-client-xlators-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
  rpm -i glusterfs-client-xlators-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
EOH
not_if 'rpm -qa | grep glusterfs-client'
end

bash "install-glusterfs-fuse" do
  code <<-EOH
  wget https://buildlogs.centos.org/centos/#{gluster_platform}/storage/x86_64/gluster-4.1/glusterfs-fuse-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
  rpm -i glusterfs-fuse-#{gluster_version}-1.el#{gluster_platform}.x86_64.rpm
EOH
  not_if 'rpm -qa | grep glusterfs-fuse'
end
