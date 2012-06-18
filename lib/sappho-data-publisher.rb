# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-basics/module_register'
require 'sappho-data-publisher/publisher'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/confluence'
require 'sappho-data-publisher/jira'
require 'sappho-data-publisher/jira_users'
require 'sappho-data-publisher/custom_liquid'
require 'sappho-data-publisher/version'

module Sappho
  module Data
    module Publisher

      class CommandLine

        def CommandLine.process
          ENV['application.log.detail'] = 'message'
          modules = Sappho::ApplicationModuleRegister.instance
          modules.get(:log).info "sappho-data-publisher version #{VERSION} - #{HOMEPAGE}"
          modules.set :configuration, Configuration.new
          jira = Jira.new
          jira.connect
          modules.set 'Jira', jira
          modules.set 'AddressBook', jira
          jiraUsers = JiraUsers.new
          jiraUsers.connect
          modules.set 'JiraUsers', jiraUsers
          confluence = Confluence.new
          confluence.connect
          modules.set 'Confluence', confluence
          CustomLiquid.setup
          Publisher.new.publish
          modules.shutdown
        end

      end

    end
  end
end
