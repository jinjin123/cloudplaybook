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

rootdir = "/home/keithyau/bootdev/shadowdock/customdomains"

  #Create root dir if it is not exists
  directory 'rootdir' do
    recursive true
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

require 'digest/sha1'
def generateKey(string)
  return Digest::SHA1.hexdigest ("#{string}")
end

def getrandomserver()
  #We only have this server for now
  return 'dev.chickenkiller.com'
end 


#Create custom domain template files, dockeruri should have domain:port
node[:customdomains].each do |username,dockeruri|
  #Bind name to xxx.shadowdock.com
  template "#{rootdir}/#{username}.domainsetting.json" do
    variables(
      :subdomain => generateKey(username),
      :bindtoserver => getrandomserver(), #Get a server to bind from our db
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




