#
# Cookbook Name:: bootdev_customdomain
# Recipe:: default
#
# Copyright 2014, BootDev
#
# All rights reserved - Do Not Redistribute
#
# BootDev defined Route53-for-customdomaiN default script
# Check if target web directory is exist, create it if not

#rootdir = "/home/keithyau/bootdev/shadowdock/customdomains"
rootdir = "#{node[:deploycode][:basedirectory]}/bootdev_customdomains"

  #Create root dir if it is not exists
  directory rootdir do
    recursive true
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

#Create custom domain template files, dockeruri should have domain:port
node[:deploycode][:runtime].each do |dockername,dockeruri|
  #Bind name to xxx.shadowdock.com
  template "#{rootdir}/#{dockername}.domainsetting.json" do
    variables(
      #ToDo: since domainprefix binded with nginx bootproxy, now only supports 1 docker per json
      #support multiple docker add in future
      :subdomain => node[:domainprefix],
      :bindtoserver => node[:thisserver], #Get a server to bind from our db
    )
    source "template.domainsetting.json"
    mode 0644
    retries 3
    retry_delay 30
    owner "root"
    group "root"
    action :create
  end
end

#Options:
#Using the above template to call route53 add or use cookbook




#Use cookbook
include_recipe "route53"

node[:deploycode][:runtime].each do |dockername,dockeruri|

  domain_type = 'CNAME';
 
  if defined?(node[:domain_type])
    domain_type = node[:domain_type]
  end

  route53_record "create #{} record" do
    name  "#{node[:domainprefix]}.#{node[:domainname]}"
    value node[:thisserver]
    type  "#{domain_type}"

    # The following are for routing policies
    # Azzume only 1 account which is shadowdock.com
    set_identifier "#{node[:thisserver]}"
    zone_id               "Z3ON58C3QO6KKR"
    aws_access_key_id     "AKIAJM5LVPWZENY6JO7Q"
    aws_secret_access_key "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"
    overwrite true
    action :create
  end
end


