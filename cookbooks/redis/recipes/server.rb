case node['redis']['install_type']
when "package"
  include_recipe "redis::server_package"
when "source"
  include_recipe "redis::server_source"
end