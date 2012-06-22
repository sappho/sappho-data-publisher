# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/atlassian_app'
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
          # process a single issue fetch request
          if id = parameters['id']
            @logger.info "fetching Jira issue #{id}"
            getJiraIssueDetails @appServer.getIssue(@token, id), pageData
          end
          # process a multi-issue, via filter, fetch request
          if filterId = parameters['filterId']
            @logger.info "fetching all Jira issues included in filter #{filterId}"
            issues = @appServer.getIssuesFromFilter @token, filterId
            pageData['issues'] = cookedIssues = []
            issues.each { |issue|
              cookedIssue = { 'key' => issue['key'] }
              getJiraIssueDetails issue, cookedIssue
              cookedIssues << cookedIssue
            }
          end
          # process a group membership fetch request
          if groupName = parameters['groupName']
            @logger.info "fetching membership of Jira user group #{groupName}"
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

        def getJiraIssueDetails issue, pageData
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
