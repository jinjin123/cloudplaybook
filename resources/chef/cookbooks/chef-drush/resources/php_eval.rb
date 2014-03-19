#
# Cookbook Name:: drush
# Resource:: php_eval
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

actions :execute
default_action :execute

# Required attributes
attribute :php, :name_attribute => true, :kind_of => String, :required => true
attribute :drupal_root, :kind_of => String, :required => true

# drush -l <http://example.com:8888>, --uri=<http://example.com:8888>
attribute :drupal_uri, :kind_of => String, :default => 'http://default'

# drush --format=<json>
attribute :format, :kind_of => String, :equal_to => ['var_export', 'csv', 'json', 'list', 'string', 'table', 'yaml'], :default => 'var_export'

# Chef::Mixin::ShellOut options
attribute :shell_user, :regex => Chef::Config[:user_valid_regex]
attribute :shell_group, :regex => Chef::Config[:group_valid_regex]
attribute :shell_timeout, :kind_of => Integer, :default => 900

attribute :block, :kind_of => Proc

def block(&block)
  if block_given? && block
    @block = block
  else
    @block
  end
end

attr_accessor :exists
