require 'rubygems'
require 'modules'
require 'confluence'
require 'jira'
gem 'liquid'
require 'liquid'
require 'yaml'

class WikiPublisher

  def publish
    modules = Modules.instance
    config = modules.get :configuration
    logger = modules.get :logger
    wiki = modules.get config.get 'config.wiki'
    pages = []
    wiki.getScript wiki.getConfiguration do |pageData|
      hash = YAML.load pageData
      page = hash['page']
      pages.push page if page
    end
    pages.each do |pageData|
      id = pageData['id']
      if pageData['publish']
        logger.report "---- publishing #{id} ----"
        pageData['sources'].each do |source|
          id = source['source']
          logger.report "collecting #{id} source data"
          modules.get(id).gatherData pageData, source['parameters']
        end
        templateSpace = pageData['templatespace']
        publicationSpace = pageData['publicationspace']
        publicationSpace = templateSpace unless publicationSpace
        templateName = pageData['template']
        pageName = pageData['pageName']
        parentPageName = pageData['parent']
        logger.report "processing template"
        template = ''
        wiki.getScript wiki.getPage templateSpace, templateName do
          |templateChunk| template += templateChunk
        end
        content = Liquid::Template.parse(template).render('data' => pageData)
        logger.report "publishing generated page"
        wiki.publish publicationSpace, parentPageName, pageName, content
      else
        logger.report "---- not publishing #{id} ----"
      end
    end
  end

end

class Configuration

  def initialize
    @config = YAML.load_file ARGV[0]
  end

  def get key
    @config[key]
  end

end

class Logger

  def report message
    puts message
  end

end

modules = Modules.instance
modules.set :configuration, Configuration.new
modules.set :logger, Logger.new
modules.set 'Jira', Jira.new
modules.set 'Confluence', Confluence.new
WikiPublisher.new.publish
modules.shutdown
