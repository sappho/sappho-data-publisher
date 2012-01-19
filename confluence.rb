require 'modules'
require 'xmlrpc/client'

class Confluence

  def initialize
    @config = Modules.instance.get :configuration
    @logger = Modules.instance.get :logger
    url = @config.get 'confluence.url'
    @wiki = XMLRPC::Client.new2("#{url}/rpc/xmlrpc").proxy('confluence1')
    @token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
    @logger.info "Confluence #{url} is online"
  end

  def getGlobalConfiguration
    pageName = @config.get('confluence.global.config.page.name')
    return getPage @config.get('confluence.config.space.key'), pageName if pageName
    ''
  end

  def getConfiguration
    getPage @config.get('confluence.config.space.key'), @config.get('confluence.config.page.name')
  end

  def getTemplate pageData, parameters
    getPage parameters['templatespace'], parameters['templatepage']
  end

  def getScript rawPage
    rawPage.scan(/\{noformat.*?\}(.*?)\{noformat\}/m).each { |pageData| yield pageData[0] }
  end

  def publish content, pageData, parameters
    setPage parameters['space'], parameters['parent'], pageData['pagename'], content
  end

  def shutdown
    @wiki.logout @token
    @logger.info 'disconnected from Confluence'
  end

  private

  def getPage spaceKey, pageName
    @logger.info "reading wiki page #{spaceKey}:#{pageName}"
    @wiki.getPage(@token, spaceKey, pageName)['content']
  end

  def setPage spaceKey, parentPageName, pageName, content
    begin
      page = @wiki.getPage(@token, spaceKey, pageName)
      page['content'] = content
      @logger.info "rewriting existing wiki page #{spaceKey}:#{pageName}"
    rescue
      page = {
        'space' => spaceKey,
        'parentId' => @wiki.getPage(@token, spaceKey, parentPageName)['id'],
        'title' => pageName,
        'content' => content }
      @logger.info "creating new wiki page #{spaceKey}:#{pageName} as child of #{parentPageName}"
    end
    @wiki.storePage @token, page
  end

end
