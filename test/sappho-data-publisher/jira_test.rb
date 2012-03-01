require "test/unit"
require 'logger'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'

module Sappho
  module Data
    module Publisher

      TOKEN = 'a-token-string'
      USERS = {
          'cgrant' => 'Cary Grant',
          'bholiday' => 'Billie Holiday'
      }
      ISSUES = {
          'TEST-42' => { 'summary' => '', 'description' => '', 'customFieldValues' => [
              { 'customfieldId' => '', 'values' => [''] }
          ] }
      }

      class JiraTest < Test::Unit::TestCase

        def setup
          @logger = Logger.new STDOUT
          @logger.level = Logger::DEBUG
          modules = Modules.instance
          modules.set :logger, @logger
          modules.set :configuration, Configuration.new(
              "#{File.dirname(__FILE__)}/../../test/configs/config.yml")
          @mockJira = MockJira.new
          modules.set :mockJira, @mockJira
          @jira = Jira.new
          modules.set 'Jira', @jira
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
          name = USERS[username]
          assert_raise RuntimeError do
            @jira.getUserFullName username
          end
          # now connect to allow the test to proceed
          connect
          # check a valid name
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, 1
          # test name caching
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, 1
          # this won't be cached'
          username = 'bholiday'
          name = USERS[username]
          assert_equal name, @jira.getUserFullName(username)
          assert_equal @mockJira.getNameCount, 2
          # check an invalid name
          assert_raise RuntimeError do
            @jira.getUserFullName('nobody')
          end
          assert_equal @mockJira.getNameCount, 3
          # check an invalid name - there should be no caching
          assert_raise RuntimeError do
            @jira.getUserFullName('nobody')
          end
          assert_equal @mockJira.getNameCount, 4
        end

        def test_data_gathering
          connect
        end

      end

      class MockJira

        attr_reader :getNameCount

        def initialize
          @getNameCount = 0
        end

        def mockInstance url
          assert_expected 'URL', url, 'https://jira.example.com'
          self
        end

        def login username, password
          assert_expected 'username', username, 'jiraadminuser'
          assert_expected 'password', password, 'secretjirapassword'
          TOKEN
        end

        def logout token
          assert_token_valid token
        end

        def getCustomFields token
          assert_token_valid token
          [
              { 'id' => '', 'name' => ''},
              { 'id' => '', 'name' => ''},
              { 'id' => '', 'name' => ''},
              { 'id' => '', 'name' => ''}
          ]
        end

        def getUser token, username
          assert_token_valid token
          @getNameCount += 1
          raise 'user unknown' unless USERS.has_key? username
          { 'fullname' => USERS[username] }
        end

        private

        def assert_expected description, actual, expected
          raise "MockJira expected #{description} of #{expected} but got #{actual}" unless actual == expected
        end

        def assert_token_valid token
          assert_expected 'token', token, TOKEN
        end

      end

    end
  end
end
