# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/jira'
require 'soap/wsdlDriver'

module Sappho
  module Data
    module Publisher

      class JiraFilter < Jira

        def gatherData pageData, parameters
          checkLoggedIn
          id = parameters['id']
          @logger.info "fetching Jira filter content #{id}"
          issues = @appServer.getIssuesFromFilter @token, id
          pageData['issues'] = cookedIssues = []
          issues.each { |issue|
            cookedIssue = { 'key' => issue['key'] }
            getJiraDetails issue, cookedIssue
            cookedIssues << cookedIssue
          }
        end

      end

    end
  end
end
