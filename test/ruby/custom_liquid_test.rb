# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'helper'
require 'liquid'
require 'sappho-data-publisher/custom_liquid'

class CustomLiquidTest < Test::Unit::TestCase

  def setup
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
