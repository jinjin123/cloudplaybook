#
# Cookbook Name:: redis
# Attributes:: default
#
# Copyright 2010, Atari, Inc
# Copyright 2012, CX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# installation
default['redis']['install_type'] = "package"
default['redis']['conf_dir'] = "/etc/redis"
default['redis']['init_style'] = "init"




# service user & group
default['redis']['user'] = "redis"
default['redis']['group'] = "redis"

# configuration
default['redis']['config']['appendonly'] = "yes"
default['redis']['config']['appendfsync'] = "everysec"
default['redis']['config']['daemonize'] = "yes"
default['redis']['config']['databases'] = "16"
default['redis']['config']['dbfilename'] = "dump.rdb"
default['redis']['config']['dir'] = "/var/lib/redis"
default['redis']['config']['listen_port'] = "6379"
default['redis']['config']['logfile'] = "stdout"
default['redis']['config']['loglevel'] = "warning"
default['redis']['config']['pidfile'] = "/var/run/redis.pid"
default['redis']['config']['rdbcompression'] = "yes"
default['redis']['config']['timeout'] = "300"
default['redis']['config']['unixsocket'] = "/var/run/redis.sock"
default['redis']['config']['unixsocketperm'] = "755"