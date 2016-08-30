directory '/mnt' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template '/root/update_hadoop_files.sh' do
  source 'update_hadoop_files.sh'
  owner 'root'
  group 'root'
  mode '0755'
end
