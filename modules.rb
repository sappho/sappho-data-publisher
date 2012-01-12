require 'singleton'

class Modules

  include Singleton

  def initialize
    @modules = {}
  end

  def set name, mod
    @modules[name] = mod
  end

  def get name
    @modules[name]
  end

  def shutdown
    each { |name, mod| mod.shutdown }
  end

  def each
    @modules.each do |name, mod|
      begin
        yield name, mod
      rescue
      end
    end
  end

end
