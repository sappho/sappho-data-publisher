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
          @token = nil
        end

        def connect
          raise "you have already attempted to connect to #{@appName}" if @appServer
          modules = Sappho::ApplicationModuleRegister.instance
          @config = modules.get :configuration
          @logger = modules.get :log
          url = @config.data["#{@appName.downcase}.url"]
          mock = "mock#{@appName}"
          @appServer = modules.set?(mock) ? modules.get(mock).mockInstance(url) : yield(url)
          @logger.info "connected to #{@appName} #{url}"
          login
        end

        def login
          @token = @appServer.login @config.data["#{@appName.downcase}.username"], @config.data["#{@appName.downcase}.password"]
          @logger.info "logged in to #{@appName}"
        end

        def logout
          if loggedIn?
            begin
              @appServer.logout @token
              @logger.info "logged out of #{@appName}"
            rescue
            end
            @token = nil
          end
        end

        def shutdown
          logout
          @appServer = nil
        end

        def loggedIn?
          @token
        end

        private

        def checkLoggedIn
          raise "you are not logged in to #{@appName}" unless loggedIn?
        end

      end

    end
  end
end
