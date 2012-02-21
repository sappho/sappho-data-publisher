require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  def CustomLiquid.setup
    Liquid::Template.register_filter(Filters)
    Liquid::Template.register_tag('squash', Squash)
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

  class Squash < Liquid::Block

    def initialize tag_name, markup, tokens
       super
    end

    def render context
      wiki = []
      super.each { |line| wiki << line unless line.strip == ''}
      wiki.join
    end

  end

end
