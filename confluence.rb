require 'Dependencies'
require 'xmlrpc/client'

class Confluence

  def initialize
    @config = Dependencies.instance.get :configuration
    @logger = Dependencies.instance.get :logger
    url = @config.get 'confluence.url'
    @wiki = XMLRPC::Client.new2("#{url}/rpc/xmlrpc").proxy('confluence1')
    @token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
    @logger.report "Confluence #{url} is online"
  end

  def getConfiguration
    getPage @config.get('confluence.config.space.key'), @config.get('confluence.config.page.name')
  end

  def getPage spaceKey, pageName
    @wiki.getPage(@token, spaceKey, pageName)['content']
  end

  def publish spaceKey, parentPageName, pageName, content
    begin
      page = @wiki.getPage(@token, spaceKey, pageName)
      page['content'] = content
    rescue Exception
      page = {
        'space' => spaceKey,
        'parentId' => @wiki.getPage(@token, spaceKey, parentPageName)['id'],
        'title' => pageName,
        'content' => content
      }
    end
    @wiki.storePage @token, page
  end

  def shutdown
    @wiki.logout @token
    @logger.report 'disconnected from Confluence'
  end

end
