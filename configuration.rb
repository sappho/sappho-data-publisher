require 'modules'
require 'yaml'

class Configuration

  def initialize
    filename = File.expand_path(ARGV[0] || 'config.yml')
    @config = YAML.load_file filename
    Modules.instance.get(:logger).warn "configuration loaded from #{filename}"
  end

  def get key
    @config[key]
  end

end
