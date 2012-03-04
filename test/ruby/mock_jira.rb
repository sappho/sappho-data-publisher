# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
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

  def getIssue token, id
    assert_token_valid token
    raise 'issue does not exist' unless @issues.has_key? id
    @issues[id]
  end

  def getUser token, username
    assert_token_valid token
    @getUserCount += 1
    raise 'user unknown' unless @users.has_key? username
    @users[username]
  end

end
