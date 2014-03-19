#
# Cookbook Name:: drush
# Resource:: make
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

# Required attributes
attribute :build_path, :name_attribute => true, :kind_of => String, :required => true
attribute :makefile, :kind_of => String, :required => true

# Chef::Mixin::ShellOut options
attribute :shell_user, :regex => Chef::Config[:user_valid_regex]
attribute :shell_group, :regex => Chef::Config[:group_valid_regex]
attribute :shell_timeout, :kind_of => Integer, :default => 900

attr_accessor :exists
