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

  def setScenario scenario
    @scenario = scenario
    @pageCache = {}
  end

  def getPage token, spaceKey, pageName
    assert_token_valid token
    space = @pageCache[spaceKey]
    @pageCache[spaceKey] = space = {} unless space
    content = space[pageName]
    unless content
      space[pageName] = content =
          File.open("#{File.dirname(__FILE__)}/../data/confluence-pages/#{@scenario}/#{spaceKey}/#{pageName}.wiki", 'rb').read
    end
    {
        'space' => spaceKey,
        'title' => pageName,
        'content' => content
    }
  end

  def storePage token, page
    assert_token_valid token
    @pageCache[page['space']][page['title']] = page['content']
  end

  def assert_page_content spaceKey, pageName, expectedContent
    raise 'page content is not as expected' unless @pageCache[spaceKey][pageName] == expectedContent
  end

end
