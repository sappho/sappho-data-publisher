# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'atlassian_app'
require 'soap/wsdlDriver'

module Sappho
  module Data
    module Publisher

      class Jira < AtlassianApp

        def connect
          super do |url|
            SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
          end
          @allCustomFields = @appServer.getCustomFields @token
          @users = {}
        end

        def gatherData pageData, parameters
          checkLoggedIn
          id = parameters['id']
          @logger.info "reading Jira issue #{id}"
          issue = @appServer.getIssue @token, id
          pageData['summary'] = summary = issue['summary']
          pageData['pagename'] = summary unless pageData['pagename']
          pageData['description'] = issue['description']
          pageData['cf'] = customFields = {}
          @allCustomFields.each { |customField|
            customFields[cfname customField['id']] = { 'name' => customField['name'] }
          }
          issue['customFieldValues'].each { |customFieldValue|
            customFields[cfname customFieldValue['customfieldId']]['values'] =
                customFieldValue['values']
          }
        end

        def getUserFullName username
          checkLoggedIn
          user = @users[username]
          unless user
            @logger.info "reading Jira user details for #{username}"
            @users[username] = user = @appServer.getUser(@token, username)
          end
          user['fullname']
        end

        private

        def cfname name
          name.sub /customfield_/, ''
        end

      end

    end
  end
end
