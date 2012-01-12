require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'

class CustomLiquid

  Jira = 'Jira'

  def CustomLiquid.setup
    Liquid::Template.register_filter(FullNameFilter)
  end

  module FullNameFilter
    def fullname username
      Modules.instance.get(Jira).getUser(username)['fullname']
    end
  end

end
