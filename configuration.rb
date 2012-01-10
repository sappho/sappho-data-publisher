require 'singleton'
require 'yaml'

class Configuration

  include Singleton

  def loadFile filename
    @config = YAML.load_file filename
  end

  def load yaml
    @config = YAML.load yaml
  end

  def get key
    @config[key]
  end

end
