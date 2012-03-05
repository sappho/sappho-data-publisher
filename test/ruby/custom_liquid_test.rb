# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'rubygems'
gem 'liquid'
require 'liquid'
require 'sappho-data-publisher/custom_liquid'
require 'helper'

class CustomLiquidTest < Test::Unit::TestCase

  def setup
    setupLogging
    setupConfiguration
    setupJira 'AddressBook'
    @jira.connect
    Sappho::Data::Publisher::CustomLiquid.setup
  end

  def test_page_generation
    template = File.open(testFilename('data/custom-liquid.template'), 'rb').read
    assert_equal File.open(testFilename('data/custom-liquid.content'), 'rb').read,
                 Liquid::Template.parse(template).render
  end

end
