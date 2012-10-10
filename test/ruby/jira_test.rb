# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'helper'

class JiraTest < Test::Unit::TestCase

  def setup
    setupConfiguration
    setupJira 'Jira'
    @expectedResults = YAML.load_file testFilename 'data/jira-results.yml'
  end

  def teardown
    assert @jira.loggedIn?, 'Jira should be logged in before shutdown'
    super
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

  def test_data_gathering_pagename_as_summary
    # pagename will be a copy of the issue summary
    assert_data_gathered({}, {'key' => 'TEST-42'}, 'TEST-42-A')
  end

  def test_data_gathering_pagename_as_supplied
    # pagename supplied already so should not be set by data gatherer
    assert_data_gathered({'pagename' => 'Test Page'}, {'key' => 'TEST-42'}, 'TEST-42-B')
  end

  def test_data_gathering_from_invalid_issue
    assert_raise RuntimeError do
      assert_data_gathered({}, {'key' => 'TEST-999'}, nil)
    end
  end

  def test_data_gathering_without_connecting
    assert_raise RuntimeError do
      # this would be okay if connected, but we're not
      assert_data_gathered({}, {'key' => 'TEST-42'}, 'TEST-42-A', true)
    end
    # keep the teardown happy by connecting anyway
    connect
  end

  def assert_data_gathered pageData, parameters, expectedResults, noConnect = false
    connect unless noConnect
    @jira.gatherData pageData, parameters
    assert_equal @expectedResults[expectedResults], pageData
  end

  def assert_full_name inc = 1
    assert_equal @fullName, @jira.getUserFullName(@username),
                 "Incorrect full name obtained for user #{@username}"
    assert_get_user_count inc
  end

  def assert_get_user_count inc
    assert_equal (@getUserCount += inc), @mockJira.getUserCount,
                 'Incorrect number of calls to Jira\'s getUser function'
  end

  def assert_full_name_failure
    assert_raise RuntimeError do
      assert_full_name
    end
  end

end
