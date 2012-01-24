require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  def CustomLiquid.setup
    Liquid::Template.register_filter(Filters)
  end

  module Filters

    def fullname username
      begin
        Modules.instance.get('AddressBook').getUserFullName(username)
      rescue
        '** John Doe **'
      end
    end

    def join text
      (text || ["This field is undefined."]).join.strip
    end

  end

end
