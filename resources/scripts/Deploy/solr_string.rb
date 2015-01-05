#!/usr/bin/ruby
file_names = ['/home/ec2-user/chef11/chef-repo/cookbooks/drupalsetting/attributes/default.rb']

file_names.each do |file_name|
  text = File.read(file_name)
  v1 = ARGV[0]
  print v1  
  new_contents = text.gsub(/variable/, v1)

  # To write changes to the file, use:
  File.open(file_name, "w") {|file| file.puts new_contents }
end
