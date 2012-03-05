require 'helper'

class ConfluenceTest < Test::Unit::TestCase

  def setup
    setupLogging
    setupConfiguration
    setupConfluence 'Confluence'
  end

  def test_config_chunking
    output = ''
    @confluence.getScript File.open(testFilename('data/confluence-chunk.input'), 'rb').read do |chunk|
      output += chunk
    end
    assert_equal File.open(testFilename('data/confluence-chunk.output'), 'rb').read, output
  end

end