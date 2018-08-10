execute 'setsebool_use_nfs_home_dirs' do
    command 'setsebool -P use_nfs_home_dirs 1'
end