# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-basics/module_register'

module Sappho
  module Data
    module Publisher

      class AtlassianApp

        def initialize
          @appName = self.class.name.split("::").last
          @appServer = nil
          @loggedIn = false
        end

        def connect
          raise "you have already attempted to connect to #{@appName}" if @appServer or @loggedIn
          modules = Sappho::ApplicationModuleRegister.instance
          @config = modules.get :configuration
          @logger = modules.get :log
          url = @config.data["#{@appName.downcase}.url"]
          mock = "mock#{@appName}"
          @appServer = modules.set?(mock) ? modules.get(mock).mockInstance(url) : yield(url)
          @token = @appServer.login @config.data["#{@appName.downcase}.username"], @config.data["#{@appName.downcase}.password"]
          @logger.info "logged into #{@appName} #{url}"
          @loggedIn = true
        end

        def shutdown
          if loggedIn?
            @appServer.logout @token
            @logger.info "logged out of #{@appName}"
          end
          @loggedIn = false
          @appServer = nil
        end

        def loggedIn?
          @appServer and @loggedIn
        end

        private

        def checkLoggedIn
          raise "you are not logged in to #{@appName}" unless loggedIn?
        end

      end

    end
  end
end
