# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'mock_atlassian_app'

class MockConfluence < MockAtlassianApp

  attr_reader :getUserCount

  def initialize
    super 'https://wiki.example.com', 'wikiuser', 'secretwikipassword'
  end

end
