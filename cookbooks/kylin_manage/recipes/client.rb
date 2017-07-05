template '/etc/chef/chefClients.template' do
    source 'chefClients.template'
    owner 'root'
    group 'root'
    mode '0744'
end

template '/root/create_client.sh' do
    source 'create_client.sh'
    owner 'root'
    group 'root'
    mode '0744'
end
# 
# execute "runchefclientcreation" do
#   command "/root/create_client.sh"
# end
