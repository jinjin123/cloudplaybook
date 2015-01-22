if File.exist?("/etc/chef/run_update.sh")
  chef_gem "chef-vault"
  require "chef-vault"
  vault = ChefVault::Item.load("secrets", "secret_key")
 # vault['secret_key'] = vault['secret_key'].tr(" ", "\n")
  # To write changes to the file, use:
  out_file = File.open("/etc/chef/secret_key", "w")
  concat_string = vault['secret_key']
 # adding a space into the end of the file to avoid being strip away all text
  out_file.puts concat_string
end