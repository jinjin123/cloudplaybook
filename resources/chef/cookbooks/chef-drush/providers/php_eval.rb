#
# Cookbook Name:: drush
# Provider:: php_eval
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

action :execute do
  if !@current_resource.exists
    Chef::Log.info("#{@new_resource}: Drupal core missing - nothing to do.")
  else
    converge_by("Create #{@new_resource}") do
      Chef::Log.info("Running #{@new_resource} at #{@new_resource.drupal_root}")

      # Clean up the PHP code, escape tickmarks.
      php_eval = @new_resource.php.gsub("'","''")

      # Execute the drush make command.
      drush_cmd "php-eval" do
        arguments "'#{php_eval}'"
        options "--format=#{new_resource.format}"

        drupal_root new_resource.drupal_root
        drupal_uri new_resource.drupal_uri

        shell_user new_resource.shell_user
        shell_group new_resource.shell_group
        shell_timeout new_resource.shell_timeout

        block { |stdout| new_resource.block.call(stdout) } if new_resource.block
      end
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::DrushPhpEval.new(@new_resource.name)
  @current_resource.drupal_root(@new_resource.drupal_root)
  if DrushHelper.drupal_present?(@current_resource.drupal_root)
    Chef::Log.debug("Drush found Drupal core at #{@current_resource.drupal_root}")
    @current_resource.exists = true
  else
    Chef::Log.debug("Drush could not find Drupal core at #{@current_resource.drupal_root}")
  end
  @current_resource
end
