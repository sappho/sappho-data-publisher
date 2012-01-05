require 'ConfluenceWiki'
require 'Jira'

class WikiPublisher

  @@sources = {
      'jira' => Jira.new
  }

  def publish
    config = Configuration.new
    wiki = ConfluenceWiki.new
    config = wiki.getPage config.get('confluence.config.space.key'), config.get('confluence.config.page.name')
    pageData = nil
    pages = []
    config.each_line do |line|
      if line =~ /^\{noformat.*\}$/
        if !pageData
          pageData = ''
        else
          pages.push eval "{ #{pageData} }"
          pageData = nil
        end
      else
        if pageData
          pageData = "#{pageData} #{line}"
        end
      end
    end
    pages.each do |pageData|
      id = pageData[:id]
      if pageData[:publish]
        report "**** Publishing #{id} ****"
        pageData[:sources].each do |source|
          id = source[:source]
          report "source: #{id}"
          @@sources[id].gather pageData, source[:parameters]
        end
        space = pageData[:space]
        pageName = pageData[:page]
        report "page: #{space}:#{pageName}"
        template = wiki.getPage space, pageData[:template]

      else
        report "**** Not publishing #{id} ****"
      end
    end
  end

  def report message
    puts message
  end

end

WikiPublisher.new.publish
