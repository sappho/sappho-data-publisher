require 'rubygems'
require 'ConfluenceWiki'
require 'Jira'
gem 'liquid'
require 'liquid'

class WikiPublisher

  @@sources = {
      'jira' => Jira.new
  }

  def publish
    config = Configuration.new
    @wiki = ConfluenceWiki.new
    pages = []
    getScript config.get('confluence.config.space.key'), config.get('confluence.config.page.name') do
      |pageData| pages.push eval "{ #{pageData} }"
    end
    pages.each do |pageData|
      id = pageData['id']
      if pageData['publish']
        report "**** Publishing #{id} ****"
        pageData['sources'].each do |source|
          id = source['source']
          report "source: #{id}"
          @@sources[id].gather pageData, source['parameters']
        end
        space = pageData['space']
        pageName = pageData['page']
        report "page: #{space}:#{pageName}"
        template = ''
        getScript space, pageData['template'] do
          |templateChunk| template += templateChunk
        end
        template = Liquid::Template.parse template
        report template.render 'pageData' => pageData
      else
        report "**** Not publishing #{id} ****"
      end
    end
  end

  def getScript spaceKey, pageName
    rawPageContent = @wiki.getPage spaceKey, pageName
    pageData = nil
    rawPageContent.each_line do |line|
      if line =~ /^\{noformat.*\}$/
        if !pageData
          pageData = ''
        else
          yield pageData
          pageData = nil
        end
      else
        if pageData
          pageData += line
        end
      end
    end
  end

  def report message
    puts message
  end

end

WikiPublisher.new.publish
