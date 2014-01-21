

pkgs = [ 'gcc', 'libstdc++-devel', 'gcc-c++', 'fuse', 'fuse-devel', 'libcurl', 'libcurl-devel', 'libxml2-devel', 'openssl-devel', 'mailcap' ]
pkgs.each do |pkg|
	package pkg do 
		action :install
	end
end


template "/etc/passwd-s3fs" do 
	source "passwd-s3fs.erb"
	mode 0640
	owner "root"
	group "root"
end

execute "installS3fsIfNotExist" do
	command "wget -O /tmp/s3fs.tar.gz http://s3fs.googlecode.com/files/s3fs-1.74.tar.gz;tar zxf /tmp/s3fs.tar.gz -C /tmp;cd /tmp/s3fs-1.74;./configure;make;make install;ln -sf /usr/local/bin/s3fs /usr/bin/s3fs;rm -Rf /tmp/s3fs.tar.gz /tmp/s3fs-1.74"
	not_if { ::File.exists?("/usr/local/bin/s3fs") }	
end

