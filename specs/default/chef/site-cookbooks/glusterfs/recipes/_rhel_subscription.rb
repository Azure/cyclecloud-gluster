bootstrap = node['cyclecloud']['bootstrap']

execute 'rhel_subscription' do
    command "subscription-manager register --username=#{node['rhel']['subscription']['username']} --password=#{node['rhel']['subscription']['password']} || subscription-manager register --activationkey=#{node['rhel']['subscription']['activation_key']} --org=#{node['rhel']['subscription']['org']} && touch #{bootstrap}/rhel_subscription.done"
    not_if { ::File.exist?("#{bootstrap}/rhel_subscription.done") }
    only_if { node['platform'] == "redhat" }
  end 

    
bash 'rhel_subscription_repo_config' do
    code <<-EOH
    subscription-manager attach --pool=#{node['rhel']['subscription']['pool']}
    subscription-manager repos --disable "*"
    subscription-manager repos --enable=rhel-7-server-rpms
    subscription-manager repos --enable=rh-gluster-3-for-rhel-7-server-rpms
    subscription-manager repos --enable=rhel-7-server-ansible-2-rpms
    subscription-manager repos --enable=rh-gluster-3-web-admin-server-for-rhel-7-server-rpms
    subscription-manager repos --enable=rh-gluster-3-web-admin-agent-for-rhel-7-server-rpms
    yum -y install ansible tendrl-ansible && touch #{bootstrap}/rhel_subscription_repo_config.done
    EOH
    not_if { ::File.exist?("#{bootstrap}/rhel_subscription_repo_config.done") }
  end
