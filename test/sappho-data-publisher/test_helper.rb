# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require "test/unit"
require 'logger'
require 'yaml'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'
require "#{File.dirname(__FILE__)}/mock_jira"

module Sappho
  module Data
    module Publisher

      module TestHelper

        def setupLogging
          @logger = Logger.new STDOUT
          @logger.level = Logger::DEBUG
          Modules.instance.set :logger, @logger
        end

        def setupConfiguration filename = "#{File.dirname(__FILE__)}/../config/config.yml"
          config = Configuration.new filename
          Modules.instance.set :configuration, config
        end

        def setupJira moduleName
          @mockJira = MockJira.new
          Modules.instance.set :mockJira, @mockJira
          @jira = Jira.new
          Modules.instance.set moduleName, @jira
        end

        def teardown
          Modules.instance.shutdown
        end

      end

    end
  end
end
