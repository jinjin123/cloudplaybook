#
# Cookbook Name:: drush
# Resource:: site_install
#
# Author:: Ben Clark <ben@benclark.com>
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
#

actions :install
default_action :install

attribute :profile, :name_attribute => true, :kind_of => String, :required => true

attribute :drupal_root, :kind_of => String, :required => true
attribute :drupal_uri, :kind_of => String, :default => 'http://default'

attribute :force, :equal_to => [true, false], :default => false

attribute :account_mail, :kind_of => String
attribute :account_pass, :kind_of => String
attribute :clean_url, :equal_to => [nil, 0, 1]
attribute :db_prefix, :kind_of => String
attribute :db_su, :kind_of => String
attribute :db_su_pw, :kind_of => String
attribute :db_url, :kind_of => String
attribute :locale, :kind_of => String
attribute :site_mail, :kind_of => String
attribute :site_name, :kind_of => String
attribute :sites_subdir, :kind_of => String

attribute :additional_arguments, :kind_of => Array, :default => []
attribute :additional_options, :kind_of => Array, :default => []

# Chef::Mixin::ShellOut options
attribute :shell_user, :regex => Chef::Config[:user_valid_regex]
attribute :shell_group, :regex => Chef::Config[:group_valid_regex]
attribute :shell_timeout, :kind_of => Integer, :default => 900

attr_accessor :exists
