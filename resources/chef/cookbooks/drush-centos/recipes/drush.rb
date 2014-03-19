execute "downloaddrush" do
        command "wget --quiet -O - http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz | tar -zxf - -C /usr/local/share"
end

execute "linkdrush" do
        command "ln -s /usr/local/share/drush/drush /usr/local/bin/drush"
        not_if { ::File.exists?("/usr/local/bin/drush") }
end

execute "preparedrush" do
        command "/usr/local/bin/drush"
end
