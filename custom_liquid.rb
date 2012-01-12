require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  Jira = 'Jira'

  def CustomLiquid.setup
    Liquid::Template.register_filter(FullNameFilter)
    Liquid::Template.register_filter(Blank)
  end

  module FullNameFilter
    def fullname username
      Modules.instance.get(Jira).getUser(username)['fullname']
    end
  end

  module Blank
    def blank text
      text = text.join if text
      return "This information has not been supplied." unless text and text.strip.length > 0
      text
    end
  end

end
