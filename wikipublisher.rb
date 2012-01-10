require 'rubygems'
require 'ConfluenceWiki'
require 'Jira'
gem 'liquid'
require 'liquid'
require 'yaml'

class WikiPublisher

  def publish
    config = $modules[:config]
    @wiki = $modules['confluence']
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
        report "**** Publishing #{id} ****"
        pageData['sources'].each do |source|
          id = source['source']
          report "collecting #{id} source data"
          $modules[id].gather pageData, source['parameters']
        end
        templateSpace = pageData['templatespace']
        publicationSpace = pageData['publicationspace']
        publicationSpace = templateSpace unless publicationSpace
        templateName = pageData['template']
        pageName = pageData['pageName']
        parentPageName = pageData['parent']
        report "using template #{templateSpace}:#{templateName}"
        template = ''
        getScript templateSpace, templateName do
          |templateChunk| template += templateChunk
        end
        content = Liquid::Template.parse(template).render('data' => pageData)
        report "publishing #{publicationSpace}:#{pageName} as child of #{parentPageName}"
        @wiki.publish publicationSpace, parentPageName, pageName, content
      else
        report "**** Not publishing #{id} ****"
      end
    end
  end

  def getScript spaceKey, pageName
    @wiki.getPage(spaceKey, pageName).scan(/\{noformat.*?\}(.*?)\{noformat\}/m).each do
      |pageData| yield pageData[0]
    end
  end

  def report message
    $modules[:logger].report message
  end

end

class Logger

  def report message
    puts message
  end

end

$modules = {
    :config => Configuration.instance,
    :logger => Logger.new,
    'confluence' => ConfluenceWiki.new,
    'Jira' => Jira.new
}

WikiPublisher.new.publish
