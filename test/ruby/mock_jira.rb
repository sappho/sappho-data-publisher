# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

class MockJira

  attr_reader :getUserCount

  def initialize filename
    data = YAML.load_file filename
    @users = data['users']
    @issues = data['issues']
    @allCustomFields = data['all_custom_fields']
    @token = 'a-token-string'
    @loggedIn = false
    @getUserCount = 0
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
    @token
  end

  def logout token
    assert_token_valid token
    @loggedIn = false
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

  private

  def check_not_logged_in
    raise 'you should not be logged in yet but you are' if @loggedIn
  end

  def assert_expected description, actual, expected
    raise "MockJira expected #{description} of #{expected} but got #{actual}" unless actual == expected
  end

  def assert_token_valid token
    raise 'you should be logged in by now but you are not' unless @loggedIn
    assert_expected 'token', token, @token
  end

end
