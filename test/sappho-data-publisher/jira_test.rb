require "test/unit"
require 'logger'
require 'yaml'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'

module Sappho
  module Data
    module Publisher

      DIR = "#{File.dirname(__FILE__)}/../"
      DATA = YAML.load_file "#{DIR}data/jira.yml"
      USERS = DATA['users']
      ISSUES = DATA['issues']
      ALL_CUSTOM_FIELDS = DATA['all_custom_fields']
      TOKEN = 'a-token-string'

      class JiraTest < Test::Unit::TestCase

        def setup
          @logger = Logger.new STDOUT
          @logger.level = Logger::DEBUG
          modules = Modules.instance
          modules.set :logger, @logger
          modules.set :configuration, Configuration.new("#{DIR}config/config.yml")
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

      class MockJira

        attr_reader :getNameCount

        def initialize
          @loggedIn = false
          @getNameCount = 0
        end

        def mockInstance url
          check_not_logged_in
          assert_expected 'URL', url, 'https://jira.example.com'
          self
        end

        def login username, password
          check_not_logged_in
          assert_expected 'username', username, 'jiraadminuser'
          assert_expected 'password', password, 'secretjirapassword'
          @loggedIn = true
          TOKEN
        end

        def logout token
          assert_token_valid token
          @loggedIn = false
        end

        def getCustomFields token
          assert_token_valid token
          ALL_CUSTOM_FIELDS
        end

        def getIssue token, id
          assert_token_valid token
          raise 'issue does not exist' unless ISSUES.has_key? id
          ISSUES[id]
        end

        def getUser token, username
          assert_token_valid token
          @getNameCount += 1
          raise 'user unknown' unless USERS.has_key? username
          USERS[username]
        end

        private

        def check_not_logged_in
          raise 'you should not be logged in yet but you are' if @loggedIn
        end

        def assert_expected description, actual, expected
          raise "MockJira expected #{description} of #{expected} but got #{actual}" unless actual == expected
        end

        def assert_token_valid token
          raise 'you should be logged in by now but you are not' unless @loggedIn
          assert_expected 'token', token, TOKEN
        end

      end

    end
  end
end
