# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'mock_atlassian_app'

class MockJira < MockAtlassianApp

  attr_reader :getUserCount

  def initialize filename
    super 'https://jira.example.com', 'jiraadminuser', 'secretjirapassword'
    data = YAML.load_file filename
    @users = data['users']
    @issues = data['issues']
    @allCustomFields = data['all_custom_fields']
    @getUserCount = 0
  end

  def getCustomFields token
    assert_token_valid token
    @allCustomFields
  end

  def getIssue token, key
    assert_token_valid token
    raise 'issue does not exist' unless @issues.has_key? key
    @issues[key]
  end

  def getUser token, username
    assert_token_valid token
    @getUserCount += 1
    raise 'user unknown' unless @users.has_key? username
    @users[username]
  end

  def getIssuesFromJqlSearch token, jql, maxResults
    assert_token_valid token
    return []
  end

end
