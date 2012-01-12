require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  Jira = 'Jira'

  def CustomLiquid.setup
    Liquid::Template.register_filter(Filters)
  end

  module Filters

    def fullname username
      Modules.instance.get(Jira).getUser(username)['fullname']
    end

    def blank text
      text = text.join if text
      return "This information has not been supplied." unless text and text.strip.length > 0
      text
    end

  end

end
