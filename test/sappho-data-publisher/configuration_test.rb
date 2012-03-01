require "test/unit"
require 'logger'
require 'sappho-data-publisher/configuration'

module Sappho
  module Data
    module Publisher

      class ConfigurationTest < Test::Unit::TestCase

        def setup
          logger = Logger.new STDOUT
          logger.level = Logger::DEBUG
          Modules.instance.set :logger, logger
          @config = Configuration.new("#{File.dirname(__FILE__)}/../data/config.yml").data
          assert_not_nil @config
        end

        def test_data_exists
          assert_equal @config['places']['Paris']['country'], 'France'
        end

        def test_data_missing
          assert_raises NoMethodError do
            @config['places']['Edinburgh']['country']
          end
        end

      end

    end
  end
end