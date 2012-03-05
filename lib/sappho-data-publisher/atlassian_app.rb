# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/modules'

module Sappho
  module Data
    module Publisher

      class AtlassianApp

        @appServer = nil
        @loggedIn = false

        def connect
          raise "you have already attempted to connect to #{self.class.name}" if @appServer or @loggedIn
          modules = Modules.instance
          config = modules.get :configuration
          @logger = modules.get :logger
          url = config.data["#{self.class.name.downcase}.url"]
          mock = "mock#{self.class.name}"
          @appServer = modules.set?(mock) ? modules.get(mock).mockInstance(url) : yield url
          @token = @appServer.login config.data["#{self.class.name.downcase}.username"], config.data["#{self.class.name.downcase}.password"]
          @logger.info "logged into #{self.class.name} #{url}"
          @loggedIn = true
        end

        def shutdown
          if loggedIn?
            @appServer.logout @token
            @logger.info "logged out of #{self.class.name}"
          end
          @loggedIn = false
          @appServer = nil
        end

        def loggedIn?
          @appServer and @loggedIn
        end

        private

        def checkLoggedIn
          raise "you are not logged in to #{self.class.name}" unless loggedIn?
        end

      end

    end
  end
end
