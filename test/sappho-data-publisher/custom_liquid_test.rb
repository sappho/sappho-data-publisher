# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'rubygems'
gem 'liquid'
require 'liquid'
require 'sappho-data-publisher/custom_liquid'
require 'test_helper'

class CustomLiquidTest < Test::Unit::TestCase

  include TestHelper

  def setup
    setupLogging
    setupConfiguration
    setupJira 'AddressBook'
    @jira.connect
    Sappho::Data::Publisher::CustomLiquid.setup
  end

  def test_page_generation
    filename = testFilename 'data/custom_liquid.'
    template = File.open("#{filename}template", "rb").read
    content = Liquid::Template.parse(template).render
    expectedContent = File.open("#{filename}content", "rb").read
    assert_equal expectedContent, content
  end

end
