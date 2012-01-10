require 'rubygems'
require 'Dependencies'
require 'confluence'
require 'Jira'
gem 'liquid'
require 'liquid'
require 'yaml'

class WikiPublisher

  def publish
    config = Dependencies.instance.modules[:configuration]
    logger = Dependencies.instance.modules[:logger]
    @wiki = Confluence.instance
    pages = []
    getScript config.get('confluence.config.space.key'), config.get('confluence.config.page.name') do
      |pageData|
      hash = YAML.load pageData
      page = hash['page']
      pages.push page if page
    end
    pages.each do |pageData|
      id = pageData['id']
      if pageData['publish']
        logger.report "**** Publishing #{id} ****"
        pageData['sources'].each do |source|
          id = source['source']
          logger.report "collecting #{id} source data"
          Dependencies.instance.modules[id].gatherData pageData, source['parameters']
        end
        templateSpace = pageData['templatespace']
        publicationSpace = pageData['publicationspace']
        publicationSpace = templateSpace unless publicationSpace
        templateName = pageData['template']
        pageName = pageData['pageName']
        parentPageName = pageData['parent']
        logger.report "using template #{templateSpace}:#{templateName}"
        template = ''
        getScript templateSpace, templateName do
          |templateChunk| template += templateChunk
        end
        content = Liquid::Template.parse(template).render('data' => pageData)
        logger.report "publishing #{publicationSpace}:#{pageName} as child of #{parentPageName}"
        @wiki.publish publicationSpace, parentPageName, pageName, content
      else
        logger.report "**** Not publishing #{id} ****"
      end
    end
  end

  def getScript spaceKey, pageName
    @wiki.getPage(spaceKey, pageName).scan(/\{noformat.*?\}(.*?)\{noformat\}/m).each do
      |pageData| yield pageData[0]
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

Dependencies.instance.modules = {
  :configuration => Configuration.new,
  :logger => Logger.new
}
Dependencies.instance.modules = Dependencies.instance.modules.merge({
  'Jira' => Jira.instance,
  'Confluence' => Confluence.instance
})
WikiPublisher.new.publish
Jira.instance.logout
Confluence.instance.logout
