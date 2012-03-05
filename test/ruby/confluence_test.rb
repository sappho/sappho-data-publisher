# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'helper'

class ConfluenceTest < Test::Unit::TestCase

  def setup
    setupLogging
    setupConfiguration
    setupConfluence 'Confluence'
    @mockConfluence.setScenario 'page-op-tests'
  end

  def teardown
    assert @confluence.loggedIn?, 'Confluence should be logged in before shutdown'
    super
    assert !@confluence.loggedIn?, 'Confluence should not be logged in after shutdown'
  end

  def connect
    assert !@confluence.loggedIn?, 'Confluence should not be logged in before connecting'
    @confluence.connect
    assert @confluence.loggedIn?, 'Confluence should be logged in after connecting'
  end

  def test_get_global_config
    connect
    assert_equal 'Global macros go here.', @confluence.getGlobalConfiguration
  end

  def test_get_config
    connect
    assert_equal 'Page specification goes here.', @confluence.getConfiguration
  end

  def test_get_template
    connect
    assert_equal 'This is a template.',
                 @confluence.getTemplate({}, {
                     'templatespace' => 'MYSPACE',
                     'templatepage' => 'Template'})
  end

  def test_publish_page
    connect
    params = {
        'space' => 'MYSPACE',
        'parent' => 'Home',
        'pagename' => 'Generated Page'
    }
    @confluence.publish 'New page content.', {}, params
    @confluence.publish 'Updated page content.', {}, params
  end

  def test_config_chunking
    connect # not actually needed but keeps teardown happy
    output = ''
    @confluence.getScript File.open(testFilename('data/confluence-chunk.input'), 'rb').read do |chunk|
      output += '----' + chunk
    end
    assert_equal File.open(testFilename('data/confluence-chunk.output'), 'rb').read, output
  end

end
