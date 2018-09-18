  execute 'allow_ssh' do
    command 'setsebool -P use_nfs_home_dirs 1'
  end
