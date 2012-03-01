require "test/unit"
require 'logger'
require 'sappho-data-publisher/configuration'
require "#{File.dirname(__FILE__)}/test_helper"

module Sappho
  module Data
    module Publisher

      class ConfigurationTest < Test::Unit::TestCase

        include TestHelper

        def setup
          setupLogging
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
