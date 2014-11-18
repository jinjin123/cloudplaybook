#
# Author:: Bez Hermoso (<bez@activelamp.com>)
# Copyright:: Copyright (c) 2014 ActiveLAMP
# License:: Apache License, Version 2.0
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
# See the License for the specific language governing permission and
# limitations under the License.
#

require 'chef/resource/deploy'

class Chef
  class Resource
    class DrupalMake < Chef::Resource::Deploy

      attr_accessor :build_themes_dir
      attr_accessor :build_modules_dir

      def initialize(name, run_context=nil)
        super
        @resource_name = :drupal_make
        @make_file = 'drupal.make'
        @themes_dir = nil
        @modules_dir = nil
        @drush = '/usr/local/bin/drush'
        @provider = Chef::Provider::DrupalMake::Timestamped
        @build_to = '_build'
        @symlink_before_migrate.clear
        @create_dirs_before_symlink.clear
        @symlinks.clear
        @purge_before_symlink.clear
        @build_themes_dir = 'sites/all/themes/custom'
        @build_modules_dir = 'sites/all/modules/custom'

      end

      def make_file(arg=nil)
        set_or_return(:make_file, arg, :kind_of => String)
      end

      def themes_dir(arg=nil, build=nil)
        build ||= @build_themes_dir
        set_or_return(:build_themes_dir, build, :kind_of => String)
        set_or_return(:themes_dir, arg, :kind_of => [String, NilClass])
      end

      def modules_dir(arg=nil, build=nil)
        build ||= @build_modules_dir
        set_or_return(:build_modules_dir, build, :kind_of => String)
        set_or_return(:modules_dir, arg, :kind_of => [String, NilClass])
      end

      def drush(arg=nil)
        set_or_return(:drush, arg, :kind_of => String)
      end

      def before_make(arg=nil, &block)
        arg ||= block
        set_or_return(:before_migrate, arg, :kind_of => [Proc, String])
      end

      def after_make(arg=nil, &block)
        arg ||= block
        set_or_return(:after_make, arg, :kind_of => [Proc, String])
      end

      def build_to(arg=nil)
        set_or_return(:build_to, arg, :kind_of => String)
      end
    end
  end
end