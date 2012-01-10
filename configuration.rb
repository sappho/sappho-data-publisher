require 'singleton'
require 'yaml'

class Configuration

  include Singleton

  def initialize filename=ARGV[0]
    @config = YAML.load_file filename
  end

  def get key
    @config[key]
  end

end
