# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/modules'
require 'soap/wsdlDriver'

module Sappho
  module Data
    module Publisher

      class Jira

        @jira = nil
        @loggedIn = false

        def connect
          raise 'you have already attempted to connect to Jira' if @jira or @loggedIn
          modules = Modules.instance
          config = modules.get :configuration
          @logger = modules.get :logger
          url = config.data['jira.url']
          @jira = modules.set?(:mockJira) ? modules.get(:mockJira).mockInstance(url) :
              SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
          @token = @jira.login config.data['jira.username'], config.data['jira.password']
          @logger.info "logged into Jira #{url}"
          @loggedIn = true
          @allCustomFields = @jira.getCustomFields @token
          @users = {}
        end

        def gatherData pageData, parameters
          checkLoggedIn
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
          checkLoggedIn
          user = @users[username]
          unless user
            @logger.info "reading Jira user details for #{username}"
            @users[username] = user = @jira.getUser(@token, username)
          end
          user['fullname']
        end

        def shutdown
          if loggedIn?
            @jira.logout @token
            @logger.info 'logged out of Jira'
          end
          @loggedIn = false
          @jira = nil
        end

        def loggedIn?
          @jira and @loggedIn
        end

        private

        def checkLoggedIn
          raise 'you are not logged in to Jira' unless loggedIn?
        end

      end

    end
  end
end
