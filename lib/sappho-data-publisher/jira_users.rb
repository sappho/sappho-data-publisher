# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/atlassian_app'
require 'soap/wsdlDriver'

module Sappho
  module Data
    module Publisher

      class JiraUsers < AtlassianApp

        def connect
          super do |url|
            SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
          end
        end

        def gatherData pageData, parameters
          checkLoggedIn
          groupName = parameters['groupName']
          @logger.info "reading Jira user group #{groupName}"
          group = @appServer.getGroup @token, groupName
          pageData['users'] = users = []
          group['users'].each {
              |user| users << {
                'username' => user['name'],
                'fullName' => user['fullname'],
                'email' => user['email']
          }}
        end

      end

    end
  end
end
