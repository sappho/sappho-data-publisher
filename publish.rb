require 'modules'
require 'logger'
require 'publisher'
require 'configuration'
require 'confluence'
require 'jira'
require 'custom_liquid'

logger = Logger.new STDOUT
logger.level = Logger::WARN
logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }

modules = Modules.instance
modules.set :logger, logger
modules.set :configuration, Configuration.new
jira = Jira.new
modules.set 'Jira', jira
modules.set 'AddressBook', jira
modules.set 'Confluence', Confluence.new

CustomLiquid.setup

Publisher.new.publish

modules.shutdown
