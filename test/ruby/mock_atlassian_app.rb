# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

class MockAtlassianApp

  def initialize expectedUrl, expectedUsername, expectedPassword
    @expectedUrl = expectedUrl
    @expectedUsername = expectedUsername
    @expectedPassword = expectedPassword
    @token = 'a-token-string'
    @loggedIn = false
  end

  def mockInstance url
    check_not_logged_in
    assert_expected 'URL', url, @expectedUrl
    self
  end

  def login username, password
    check_not_logged_in
    assert_expected 'username', username, @expectedUsername
    assert_expected 'password', password, @expectedPassword
    @loggedIn = true
    @token
  end

  def logout token
    assert_token_valid token
    @loggedIn = false
  end

  private

  def check_not_logged_in
    raise 'you should not be logged in yet but you are' if @loggedIn
  end

  def assert_expected description, actual, expected
    raise "expected #{description} of #{expected} but got #{actual}" unless actual == expected
  end

  def assert_token_valid token
    raise 'you should be logged in by now but you are not' unless @loggedIn
    assert_expected 'token', token, @token
  end

end
