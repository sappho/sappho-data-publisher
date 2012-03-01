require "test/unit"
require 'logger'
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

        def setupConfiguration
          Modules.instance.set :configuration, Configuration.new("#{File.dirname(__FILE__)}/../config/config.yml")
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
