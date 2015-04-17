#
# Cookbook Name:: solr
# Recipe:: default
#
# Copyright 2013, David Radcliffe
#

include_recipe 'apt::default'

include_recipe 'java' if node['solr']['install_java']

src_filename = ::File.basename(node['solr']['url'])
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{node['solr']['dir']}-#{node['solr']['version']}"

remote_file src_filepath do
  source node['solr']['url']
  action :create_if_missing
end

bash 'unpack_solr' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p #{extract_path}
    tar xzf #{src_filename} -C #{extract_path} --strip 1
  EOH
  not_if { ::File.exist?(extract_path) }
end

directory node['solr']['data_dir'] do
  owner 'root'
  group 'root'
  recursive true
  action :create
end

template 'synonyms.txt' do
  source 'synonyms.txt'
  path "#{extract_path}/example/solr/collection1/conf/synonyms.txt"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'schema.xml' do
  source 'schema.xml'
  path "#{extract_path}/example/solr/collection1/conf/schema.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'stopwords.txt' do
  source 'stopwords.txt'
  path "#{extract_path}/example/solr/collection1/conf/stopwords.txt"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'solrcore.properties' do
  source 'solrcore.properties'
  path "#{extract_path}/example/solr/collection1/conf/solrcore.properties"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'solrconfig_extra.xml' do
  source 'solrconfig_extra.xml'
  path "#{extract_path}/example/solr/collection1/conf/solrconfig_extra.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'solrconfig.xml' do
  source 'solrconfig.xml'
  path "#{extract_path}/example/solr/collection1/conf/solrconfig.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'schema_extra_types.xml' do
  source 'schema_extra_types.xml'
  path "#{extract_path}/example/solr/collection1/conf/schema_extra_types.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'schema_extra_fields.xml' do
  source 'schema_extra_fields.xml'
  path "#{extract_path}/example/solr/collection1/conf/schema_extra_fields.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'protwords.txt' do
  source 'protwords.txt'
  path "#{extract_path}/example/solr/collection1/conf/protwords.txt"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'mapping-ISOLatin1Accent.txt' do
  source 'mapping-ISOLatin1Accent.txt'
  path "#{extract_path}/example/solr/collection1/conf/mapping-ISOLatin1Accent.txt"
  owner 'root'
  group 'root'
  mode '0755'
end

template 'elevate.xml' do
  source 'elevate.xml'
  path "#{extract_path}/example/solr/collection1/conf/elevate.xml"
  owner 'root'
  group 'root'
  mode '0755'
end

template '/var/lib/solr.start' do
  source 'solr.start.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :solr_dir => extract_path,
    :solr_home => node['solr']['data_dir'],
    :port => node['solr']['port'],
    :pid_file => node['solr']['pid_file'],
    :log_file => node['solr']['log_file']
  )
  only_if { !platform_family?('debian') }
end

template '/etc/init.d/solr' do
  source platform_family?('debian') ? 'initd.debian.erb' : 'initd.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :solr_dir => extract_path,
    :solr_home => node['solr']['data_dir'],
    :port => node['solr']['port'],
    :pid_file => node['solr']['pid_file'],
    :log_file => node['solr']['log_file']
  )
end

service 'solr' do
  supports :restart => true, :status => true
  action [:enable, :start]
end
