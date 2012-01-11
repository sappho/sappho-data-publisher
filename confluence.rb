require 'modules'
require 'xmlrpc/client'

class Confluence

  def initialize
    @config = Modules.instance.get :configuration
    @logger = Modules.instance.get :logger
    url = @config.get 'confluence.url'
    @wiki = XMLRPC::Client.new2("#{url}/rpc/xmlrpc").proxy('confluence1')
    @token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
    @logger.report "Confluence #{url} is online"
  end

  def getConfiguration
    getPage @config.get('confluence.config.space.key'), @config.get('confluence.config.page.name')
  end

  def getTemplate pageData, parameters
    getPage parameters['templatespace'], parameters['templatepage']
  end

  def getScript rawPage
    rawPage.scan(/\{noformat.*?\}(.*?)\{noformat\}/m).each do
      |pageData| yield pageData[0]
    end
  end

  def publish content, pageData, parameters
    setPage parameters['space'], parameters['parent'], pageData['pagename'], content
  end

  def shutdown
    @wiki.logout @token
    @logger.report 'disconnected from Confluence'
  end

  private

  def getPage spaceKey, pageName
    @logger.report "reading wiki page #{spaceKey}:#{pageName}"
    @wiki.getPage(@token, spaceKey, pageName)['content']
  end

  def setPage spaceKey, parentPageName, pageName, content
    begin
      page = @wiki.getPage(@token, spaceKey, pageName)
      page['content'] = content
      @logger.report "rewriting existing wiki page #{spaceKey}:#{pageName}"
    rescue Exception
      page = {
        'space' => spaceKey,
        'parentId' => @wiki.getPage(@token, spaceKey, parentPageName)['id'],
        'title' => pageName,
        'content' => content
      }
      @logger.report "creating new wiki page #{spaceKey}:#{pageName} as child of #{parentPageName}"
    end
    @wiki.storePage @token, page
  end

end
