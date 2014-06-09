#
# Cookbook Name:: microcache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/root/header.txt" do
        source "header.erb"
        mode 0600
        owner "root"
        group "root"
end

template "/root/locationphp.txt" do
        source "locationphp.erb"
        mode 0600
        owner "root"
        group "root"
end

template "/root/server.txt" do
        source "server.erb"
        mode 0600
        owner "root"
        group "root"
end

script "insert" do
        interpreter "bash"
        user "root"
        code <<-EOH
            tac /root/locationphp.txt > /root/re_locationphp.txt
            tac /root/server.txt > /root/re_server.txt
            tac /root/header.txt > /root/re_header.txt

            while read line
            do
            sed '20 i $line' /etc/nginx/sites-available/default
            done < /root/re_locationphp.txt

            while read line
            do
            sed '7 i $line' /etc/nginx/sites-available/default
            done < /root/re_server.txt

            while read line
            do
            sed '1 i $line' /etc/nginx/sites-available/default
            done < /root/re_header.txt

            rm /root/*.txt           

        EOH
end
