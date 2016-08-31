template '/etc/chef/chefClients.template' do
    source 'chefClients.template'
    owner 'root'
    group 'root'
    mode '0744'
end
