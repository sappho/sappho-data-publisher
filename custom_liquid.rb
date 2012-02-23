require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  def CustomLiquid.setup
    Liquid::Template.register_filter(Fullname)
    Liquid::Template.register_tag('squash', Squash)
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
      @message = (markup ? markup.to_s : '')
      @message = @message.length > 0 ? @message : '_This information has not been supplied._'
    end

    def render context
      wiki = []
      super.each { |line| wiki << line unless line.strip == ''}
      wiki.size > 0 ? wiki.join : @message
    end

  end

end
