require "test/unit"
require 'logger'
require 'yaml'
require 'rubygems'
gem 'liquid'
require 'liquid'
require 'sappho-data-publisher/custom_liquid'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'
TESTDIR = File.dirname(__FILE__)
require "#{TESTDIR}/mock_jira"

module Sappho
  module Data
    module Publisher

      class CustomLiquidTest < Test::Unit::TestCase

        def setup
          @logger = Logger.new STDOUT
          @logger.level = Logger::DEBUG
          modules = Modules.instance
          modules.set :logger, @logger
          modules.set :configuration, Configuration.new("#{TESTDIR}/../config/config.yml")
          @mockJira = MockJira.new
          modules.set :mockJira, @mockJira
          @jira = Jira.new
          modules.set 'AddressBook', @jira
          @jira.connect
          CustomLiquid.setup
        end

        def teardown
          Modules.instance.shutdown
        end

        def test_page_generation
          template = File.open("#{TESTDIR}/../data/custom_liquid.template", "rb").read
          content = Liquid::Template.parse(template).render({})
          expectedContent = File.open("#{TESTDIR}/../data/custom_liquid.content", "rb").read
          assert_equal expectedContent, content
        end

      end

    end
  end
end
