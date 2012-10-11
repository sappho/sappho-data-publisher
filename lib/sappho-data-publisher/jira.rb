# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
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
          if key = parameters['key']
            @logger.info "fetching Jira issue #{key}"
            issue = @appServer.getIssue(@token, key)
            pageData['pagename'] = issue['summary'] unless pageData['pagename']
            processIssues pageData, [issue]
          end
          # process a multi-issue, via filter, fetch request
          if filterId = parameters['filterId']
            @logger.info "fetching all Jira issues included in filter #{filterId}"
            issues = @appServer.getIssuesFromFilter @token, filterId
            processIssues pageData, issues
          end
          # process a multi-issue, via JQL, fetch request
          if jql = parameters['jql']
            maxResults = parameters['max']
            issues = jqlQuery jql, maxResults
            processIssues pageData, issues
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
              } }
          end
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

        def processIssues pageData, issues
          pageData['issues'] = cookedIssues = []
          cookIssues issues, cookedIssues
        end

        def jqlQuery jql, maxresults
          @logger.info "fetching up to #{maxresults} Jira issues for #{jql}"
          @appServer.getIssuesFromJqlSearch @token, jql, maxresults
        end

        def cookIssues issues, cookedIssues
          issues.each { |issue|
            cookedIssue = {}
            ['id', 'key', 'summary', 'description', 'assignee', 'created', 'duedate', 'priority',
             'project', 'reporter', 'resolution', 'status', 'type', 'updated'].each { |key|
              cookedIssue[key] = issue[key]
            }
            cookedIssue['components'] = components = []
            issue['components'].each { |component| components << component['name'] }
            cookedIssue['cf'] = customFields = {}
            @allCustomFields.each { |customField|
              customFields[cfname customField['id']] = {'name' => customField['name']}
            }
            issue['customFieldValues'].each { |customFieldValue|
              customFields[cfname customFieldValue['customfieldId']]['values'] =
                  customFieldValue['values']
            }
            cookedIssue['subtasks'] = cookedSubtasks = []
            subtasks = jqlQuery "parent=#{issue['key']}", 100
            cookIssues subtasks, cookedSubtasks
            cookedIssues << cookedIssue
          }
        end

        def cfname name
          name.sub /customfield_/, ''
        end

      end

    end
  end
end
