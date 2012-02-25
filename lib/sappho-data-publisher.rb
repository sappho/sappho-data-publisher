# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'logger'
require 'sappho-data-publisher/modules'
require 'sappho-data-publisher/publisher'
require 'sappho-data-publisher/configuration'
require 'sappho-data-publisher/confluence'
require 'sappho-data-publisher/jira'
require 'sappho-data-publisher/custom_liquid'
require 'sappho-data-publisher/version'

module Sappho
  module Data
    module Publisher

      class CommandLine

        def run
          logger = Logger.new STDOUT
          logger.level = Logger::INFO
          logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
          logger.info "sappho-data-publisher version #{VERSION} - #{HOMEPAGE}"
          modules = Modules.instance
          modules.set :logger, logger
          modules.set :configuration, Configuration.new
          modules.set 'Jira', (jira = Jira.new)
          modules.set 'AddressBook', jira
          modules.set 'Confluence', Confluence.new
          CustomLiquid.setup
          Publisher.new.publish
          modules.shutdown
        end

      end

    end
  end
end
