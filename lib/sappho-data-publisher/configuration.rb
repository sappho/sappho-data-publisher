# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-basics/module_register'
require 'yaml'

module Sappho
  module Data
    module Publisher

      class Configuration

        attr_reader :data

        def initialize filename = ARGV[0]
          filename = File.expand_path(filename || 'config.yml')
          @data = YAML.load_file filename
          Sappho::ApplicationModuleRegister.instance.get(:log).info "configuration loaded from #{filename}"
        end

      end

    end
  end
end
