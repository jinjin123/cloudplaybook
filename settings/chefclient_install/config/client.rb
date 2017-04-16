log_level      :info
log_location    STDOUT
chef_server_url 'https://CHEFSERVER_ADDR:443/organizations/admin'
node_name 'NODE_NAME'
no_lazy_load true
ssl_verify_mode :verify_none
validation_client_name  'VALIDATE_NAME'
validation_key '/etc/chef/VALIDATE_NAME.pem'
