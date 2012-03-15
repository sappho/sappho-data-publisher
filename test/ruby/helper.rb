# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'rubygems'
require 'test/unit'
require 'yaml'
require 'sappho-basics/module_register'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/jira'
require 'sappho-data-publisher/confluence'
require 'mock_jira'
require 'mock_confluence'

class Test::Unit::TestCase

  def setupConfiguration (filename = testFilename('config/config.yml'))
    config = Sappho::Data::Publisher::Configuration.new filename
    Sappho::ModuleRegister.instance.set :configuration, config
  end

  def setupJira (moduleName, dataFilename = testFilename('data/jira.yml'))
    @mockJira = MockJira.new dataFilename
    Sappho::ModuleRegister.instance.set 'mockJira', @mockJira
    @jira = Sappho::Data::Publisher::Jira.new
    Sappho::ModuleRegister.instance.set moduleName, @jira
  end

  def setupConfluence moduleName
    @mockConfluence = MockConfluence.new
    Sappho::ModuleRegister.instance.set 'mockConfluence', @mockConfluence
    @confluence = Sappho::Data::Publisher::Confluence.new
    Sappho::ModuleRegister.instance.set moduleName, @confluence
  end

  def teardown
    Sappho::ModuleRegister.instance.shutdown
  end

  def testFilename filename
    "#{File.dirname(__FILE__)}/../#{filename}"
  end

end
