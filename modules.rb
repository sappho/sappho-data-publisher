require 'singleton'

class Modules

  include Singleton

  def initialize
    @modules = {}
  end

  def set key, mod
    @modules[key] = mod
  end

  def get key
    @modules[key]
  end

  def shutdown
    @modules.each do |key, mod|
      begin
        mod.shutdown
      rescue Exception
      end
    end
  end

end
