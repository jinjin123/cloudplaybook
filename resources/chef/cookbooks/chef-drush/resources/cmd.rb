#
# Cookbook Name:: drush
# Resource:: cmd
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

# drush <command> [<arguments> [<options>]]
attribute :command, :name_attribute => true, :kind_of => String, :required => true
attribute :arguments, :kind_of => [ String, Array ]
attribute :options, :kind_of => [ String, Array ]

# drush -r <path>, --root=<path>
attribute :drupal_root, :kind_of => String, :required => true

# drush -l <http://example.com:8888>, --uri=<http://example.com:8888>
attribute :drupal_uri, :kind_of => String, :default => 'http://default'

# drush -y, --yes
attribute :assume_yes, :equal_to => [true, false], :default => true

# drush -n, --no
attribute :assume_no, :equal_to => [true, false], :default => false

# drush --backend
attribute :backend, :equal_to => [ true, false], :default => false

# Chef::Mixin::ShellOut options
attribute :shell_input, :kind_of => String
attribute :shell_timeout, :kind_of => Integer, :default => 900
attribute :shell_user, :regex => Chef::Config[:user_valid_regex]
attribute :shell_group, :regex => Chef::Config[:group_valid_regex]

attribute :block, :kind_of => Proc

def block(&block)
  if block_given? && block
    @block = block
  else
    @block
  end
end
