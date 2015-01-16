#
# Cookbook Name:: updatevault
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
#
directory "/home/ec2-user/.pem" do
  owner 'root'
  group 'root'
  mode '0744'
  action :create
  ignore_failure true
end

template "/home/ec2-user/.pem/drucloud.pem" do
  source "drucloud.pem"
  mode 0400
  retries 3
  retry_delay 30
  owner "root"
  group "root"
  action :create
  ignore_failure true
end rescue NoMethodError

script "install_drush_root" do
  interpreter "bash"
  user "root"
  code <<-EOH
  cd
  nohup /usr/local/bin/composer global require drush/drush:dev-master &
  sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
  source $HOME/.bashrc
  EOH
end
