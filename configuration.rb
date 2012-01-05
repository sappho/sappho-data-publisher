require 'yaml'

class Configuration

  def initialize
    @config = YAML.load_file getFilename
  end

  def get key
    @config[key]
  end

  def getFilename
    ARGV[0]
  end

end
