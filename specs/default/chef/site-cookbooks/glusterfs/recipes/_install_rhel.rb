bootstrap = node['cyclecloud']['bootstrap']

%w(redhat-storage-server gstatus).each do |pkg|
  package pkg
end

bash 'rhel_firewall' do
  code <<-EOH
  firewall-cmd --zone=public --add-service=glusterfs --permanent
  firewall-cmd --reload
  touch #{bootstrap}/rhel_firewall.done
  EOH
  not_if { ::File.exist?("#{bootstrap}/rhel_firewall.done") }
end