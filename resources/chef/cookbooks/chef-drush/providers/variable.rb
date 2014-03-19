#
# Cookbook Name:: drush
# Provider:: variable
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

# Support whyrun
def whyrun_supported?
  true
end

action :set do
  if !@current_resource.exists
    Chef::Log.info("#{@new_resource}: Drupal could not be bootstrapped - nothing to do.")
  elsif DrushHelper.drush_vget_match?(@new_resource.drupal_root, @new_resource.name, @new_resource.value, @new_resource.drupal_uri)
    Chef::Log.info("#{@new_resource}: Drupal variable matches value - nothing to do.")
  else
    converge_by("Create #{@new_resource}") do
      Chef::Log.info("Running #{@new_resource} at #{@new_resource.drupal_root}")

      # Set drush options
      options = [ "--exact" ]

      # Format the value as JSON if it's a Hash or Array
      value = @new_resource.value
      if value.is_a?(Hash) || value.is_a?(Array)
        value_json = JSON.generate(value)
        options << "--format=json"
      # Format the value as String if it's not already
      elsif !value.is_a?(String)
        value = value.to_s
      end

      # Execute the drush make command.
      drush_cmd "vset" do
        arguments [ new_resource.name, value_json ? "-" : value ]
        options options

        drupal_root new_resource.drupal_root
        drupal_uri new_resource.drupal_uri

        # Pipe the JSON value into the command
        shell_input value_json.to_s if value_json

        shell_user new_resource.shell_user
        shell_group new_resource.shell_group
        shell_timeout new_resource.shell_timeout
      end
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DrushVariable.new(@new_resource.name)
  @current_resource.drupal_root(@new_resource.drupal_root)
  @current_resource.drupal_uri(@new_resource.drupal_uri)
  if DrushHelper.drupal_installed?(@current_resource.drupal_root, @current_resource.drupal_uri)
    Chef::Log.debug("Drush bootstrapped Drupal at #{@current_resource.drupal_root}")
    @current_resource.exists = true
  else
    Chef::Log.debug("Drush could not bootstrap Drupal at #{@current_resource.drupal_root}")
  end
  @current_resource
end
