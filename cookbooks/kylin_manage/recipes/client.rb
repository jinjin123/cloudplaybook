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

# Replacement of region
execute "changingS3Region" do
  command "if [[ $(/home/ec2-user/tools/ec2-metadata --availability-zone| awk {'print $2'}) != *\"cn-north-1\"* ]];then sed -i 's/aws-cn/aws/' /etc/chef/chefClients.template;fi"
end
