require 'Configuration'
require 'xmlrpc/client'

class ConfluenceWiki

  def initialize
    @config = Configuration.instance
    @wiki = XMLRPC::Client.new2("#{@config.get 'confluence.url'}/rpc/xmlrpc").proxy('confluence1')
  end

  def getPage spaceKey, pageName
    content = nil
    session { |token| content = @wiki.getPage(token, spaceKey, pageName)['content'] }
    content
  end

  def publish spaceKey, parentPageName, pageName, content
    session { |token|
      page = nil
      begin
        page = @wiki.getPage(token, spaceKey, pageName)
        page['content'] = content
      rescue Exception
        page = {
            'space' => spaceKey,
            'parentId' => @wiki.getPage(token, spaceKey, parentPageName)['id'],
            'title' => pageName,
            'content' => content }
      end
      @wiki.storePage token, page
    }
  end

  private

  def session
    token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
    yield token
    @wiki.logout token
  end

end
