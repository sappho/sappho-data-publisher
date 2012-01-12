require 'yaml'

class Configuration

  def initialize
    @config = YAML.load_file ARGV[0]
  end

  def get key
    @config[key]
  end

end
