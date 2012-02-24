# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'modules'
require 'logger'
require 'publisher'
require 'configuration'
require 'confluence'
require 'jira'
require 'custom_liquid'

logger = Logger.new STDOUT
logger.level = Logger::INFO
logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }

modules = Modules.instance
modules.set :logger, logger
modules.set :configuration, Configuration.new
modules.set 'Jira', (jira = Jira.new)
modules.set 'AddressBook', jira
modules.set 'Confluence', Confluence.new
CustomLiquid.setup

Publisher.new.publish

modules.shutdown
