# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'modules'
require 'yaml'

module Sappho
  module Data
    module Publisher

      class Configuration

        attr_reader :data

        def initialize
          filename = File.expand_path(ARGV[0] || 'config.yml')
          @data = YAML.load_file filename
          Modules.instance.get(:logger).warn "configuration loaded from #{filename}"
        end

      end

    end
  end
end
