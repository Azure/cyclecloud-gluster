
bootstrap = node['cyclecloud']['bootstrap']

package 'psmisc'

bash "install-glusterfs-libs" do
    code <<-EOH
  wget --no-cache https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-4.1/glusterfs-libs-4.1.1-1.el7.x86_64.rpm
  rpm -i glusterfs-libs-4.1.1-1.el7.x86_64.rpm
  EOH
  not_if 'rpm -qa | grep glusterfs-libs'
end

bash "install-glusterfs" do
  code <<-EOH
  wget --no-cache https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-4.1/glusterfs-4.1.1-1.el7.x86_64.rpm
  rpm -i glusterfs-4.1.1-1.el7.x86_64.rpm
touch #{bootstrap}/glusterfs.installed
EOH
creates #{bootstrap}/glusterfs.installed
end

bash "install-glusterfs-client-xlators" do
  code <<-EOH
  wget https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-4.1/glusterfs-client-xlators-4.1.1-1.el7.x86_64.rpm
  rpm -i glusterfs-client-xlators-4.1.1-1.el7.x86_64.rpm
EOH
not_if 'rpm -qa | grep glusterfs-client'
end

bash "install-glusterfs-fuse" do
  code <<-EOH
  wget https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-4.1/glusterfs-fuse-4.1.1-1.el7.x86_64.rpm
  rpm -i glusterfs-fuse-4.1.1-1.el7.x86_64.rpm
EOH
  not_if 'rpm -qa | grep glusterfs-fuse'
end
