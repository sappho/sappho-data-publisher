require 'modules'
require 'yaml'

class Configuration

  attr_reader :data

  def initialize
    filename = File.expand_path(ARGV[0] || 'config.yml')
    @data = YAML.load_file filename
    Modules.instance.get(:logger).warn "configuration loaded from #{filename}"
  end

end
