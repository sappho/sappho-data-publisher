require "test/unit"
require 'logger'
require 'yaml'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'
require "#{File.dirname(__FILE__)}/mock_jira"
require "#{File.dirname(__FILE__)}/test_helper"

module Sappho
  module Data
    module Publisher

      class JiraTest < Test::Unit::TestCase

        include TestHelper

        def setup
          setupLogging
          setupConfiguration
          setupJira 'Jira'
        end

        def teardown
          assert @jira.loggedIn?, 'Jira should be logged in before shutdown'
          Modules.instance.shutdown
          assert !@jira.loggedIn?, 'Jira should not be logged in after shutdown'
        end

        def connect
          assert !@jira.loggedIn?, 'Jira should not be logged in before connecting'
          @jira.connect
          assert @jira.loggedIn?, 'Jira should be logged in after connecting'
        end

        def test_get_user_full_name
          # check a valid name but before connecting to Jira
          username = 'cgrant'
          name = 'Cary Grant'
          assert_raise RuntimeError do
            @jira.getUserFullName username
          end
          # now connect to allow the test to proceed
          connect
          count = 0
          # check a valid name
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, (count += 1)
          # test name caching
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, count
          # this won't be cached
          username = 'bholiday'
          name = 'Billie Holiday'
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, (count += 1)
          # check an invalid name
          username = 'nobody'
          assert_raise RuntimeError do
            @jira.getUserFullName(username)
          end
          assert_equal @mockJira.getNameCount, (count += 1)
          # check an invalid name - there should be no caching
          assert_raise RuntimeError do
            @jira.getUserFullName(username)
          end
          assert_equal @mockJira.getNameCount, (count += 1)
        end

        def test_data_gathering
          connect
        end

      end

    end
  end
end
