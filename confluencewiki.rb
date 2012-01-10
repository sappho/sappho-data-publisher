require 'singleton'
require 'Configuration'
require 'xmlrpc/client'

class ConfluenceWiki

  include Singleton

  def initialize
    @config = Configuration.instance
    @wiki = XMLRPC::Client.new2("#{@config.get 'confluence.url'}/rpc/xmlrpc").proxy('confluence1')
    @token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
  end

  def getPage spaceKey, pageName
    @wiki.getPage(@token, spaceKey, pageName)['content']
  end

  def publish spaceKey, parentPageName, pageName, content
    page = nil
    begin
      page = @wiki.getPage(@token, spaceKey, pageName)
      page['content'] = content
    rescue Exception
      page = {
          'space' => spaceKey,
          'parentId' => @wiki.getPage(@token, spaceKey, parentPageName)['id'],
          'title' => pageName,
          'content' => content }
    end
    @wiki.storePage @token, page
  end

  def logout
    @wiki.logout @token
  end

end
