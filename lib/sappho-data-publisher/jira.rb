# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'modules'
require 'soap/wsdlDriver'

module Sappho
  module Data
    module Publisher

      class Jira

        def initialize
          config = Modules.instance.get :configuration
          @logger = Modules.instance.get :logger
          url = config.data['jira.url']
          @jira = SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
          @token = @jira.login config.data['jira.username'], config.data['jira.password']
          @allCustomFields = @jira.getCustomFields @token
          @logger.info "Jira #{url} is online"
          @users = {}
        end

        def gatherData pageData, parameters
          id = parameters['id']
          @logger.info "reading Jira issue #{id}"
          issue = @jira.getIssue @token, id
          pageData['summary'] = summary = issue['summary']
          pageData['pagename'] = summary unless pageData['pagename']
          pageData['description'] = issue['description']
          pageData['customFields'] = customFields = {}
          @allCustomFields.each { |customField|
            customFields[customField['id']] = {
                'name' => customField['name'],
                'values' => nil
            }
          }
          issue['customFieldValues'].each { |customFieldValue|
            customFields[customFieldValue['customfieldId']]['values'] = customFieldValue['values']
          }
        end

        def getUserFullName username
          user = @users[username]
          unless user
            @logger.info "reading Jira user details for #{username}"
            @users[username] = user = @jira.getUser(@token, username)
          end
          user['fullname']
        end

        def shutdown
          @jira.logout @token
          @logger.info 'disconnected from Jira'
        end

      end

    end
  end
end
