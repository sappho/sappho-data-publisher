require 'singleton'

class Dependencies

  include Singleton

  attr_reader :modules
  attr_writer :modules

end
