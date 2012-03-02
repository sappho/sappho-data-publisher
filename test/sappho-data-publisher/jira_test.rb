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
          @getUserCount = 0
          # check a valid name but before connecting to Jira
          @username = 'cgrant'
          @fullName = 'Cary Grant'
          assert_full_name_failure
          # now connect to allow the test to proceed
          connect
          # check a valid name
          assert_full_name
          # test name caching
          assert_full_name 0
          # this won't be cached
          @username = 'bholiday'
          @fullName = 'Billie Holiday'
          assert_full_name
          # check an invalid name
          @username = 'nobody'
          assert_full_name_failure
          # check an invalid name - there should be no caching
          assert_full_name_failure
          assert_get_user_count 2
          # check a valid name again
          @username = 'cgrant'
          @fullName = 'Cary Grant'
          assert_full_name 0
        end

        def test_data_gathering
          connect
        end

        def assert_full_name inc = 1
          assert_equal @fullName, @jira.getUserFullName(@username), "Incorrect full name obtained for user #{@username}"
          assert_get_user_count inc
        end

        def assert_get_user_count inc
          assert_equal (@getUserCount += inc), @mockJira.getUserCount, 'Incorrect number of calls to Jira\'s getUser function'
        end

        def assert_full_name_failure
          assert_raise RuntimeError do
            assert_full_name
          end
        end

       end

    end
  end
end
