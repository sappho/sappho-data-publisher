# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require "test/unit"
require 'logger'
require 'yaml'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'
require 'mock_jira'

class Test::Unit::TestCase

  def setupLogging
    @logger = Logger.new STDOUT
    @logger.level = Logger::DEBUG
    Sappho::Data::Publisher::Modules.instance.set :logger, @logger
  end

  def setupConfiguration (filename = testFilename('config/config.yml'))
    config = Sappho::Data::Publisher::Configuration.new filename
    Sappho::Data::Publisher::Modules.instance.set :configuration, config
  end

  def setupJira (moduleName, dataFilename = testFilename('data/jira.yml'))
    @mockJira = MockJira.new dataFilename
    Sappho::Data::Publisher::Modules.instance.set 'mockJira', @mockJira
    @jira = Sappho::Data::Publisher::Jira.new
    Sappho::Data::Publisher::Modules.instance.set moduleName, @jira
  end

  def setupConfluence moduleName
    @mockConfluence = MockConfluence.new
    Sappho::Data::Publisher::Modules.instance.set 'mockConfluence', @mockConfluence
    @confluence = Sappho::Data::Publisher::Confluence.new
    Sappho::Data::Publisher::Modules.instance.set moduleName, @confluence
  end

  def teardown
    Sappho::Data::Publisher::Modules.instance.shutdown
  end

  def testFilename filename
    "#{File.dirname(__FILE__)}/../#{filename}"
  end

end
