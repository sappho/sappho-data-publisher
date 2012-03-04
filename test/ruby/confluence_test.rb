require 'helper'

class ConfluenceTest < Test::Unit::TestCase

  def setup
    setupLogging
    setupConfiguration
    setupConfluence 'Confluence'
  end

  def test_fail

    # To change this template use File | Settings | File Templates.
    fail("Not implemented")
  end

end