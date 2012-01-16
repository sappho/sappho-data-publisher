require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  def initialize
    Liquid::Template.register_filter(Filters)
  end

  module Filters

    def fullname username
      begin
        Modules.instance.get('AddressBook').getUser(username)['fullname']
      rescue
        '** John Doe **'
      end
    end

    def blank text
      text = text.join.strip if text
      return "This information has not been supplied." unless text and text.length > 0
      text
    end

  end

end
