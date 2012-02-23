require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  def CustomLiquid.setup
    Liquid::Template.register_filter(Fullname)
    Liquid::Template.register_tag('squash', Squash)
    Liquid::Template.register_tag('notknown', NotKnown)
  end

  module Fullname

    def fullname username
      begin
        Modules.instance.get('AddressBook').getUserFullName(username)
      rescue
        '** John Doe **'
      end
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

  class NotKnown < Liquid::Block

    def initialize tag_name, markup, tokens
       super
    end

    def render context
      wiki = super.strip
      wiki.length > 0 ? wiki : '_This information has not been supplied._'
    end

  end

end
