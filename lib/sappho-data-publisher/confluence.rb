# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'modules'
require 'xmlrpc/client'

class Confluence

  def initialize
    @config = Modules.instance.get :configuration
    @logger = Modules.instance.get :logger
    url = @config.data['confluence.url']
    @wiki = XMLRPC::Client.new2("#{url}/rpc/xmlrpc").proxy('confluence1')
    @token = @wiki.login @config.data['confluence.username'], @config.data['confluence.password']
    @logger.info "Confluence #{url} is online"
  end

  def getGlobalConfiguration
    pageName = @config.data['confluence.global.config.page.name']
    return getPage @config.data['confluence.config.space.key'], pageName if pageName
    ''
  end

  def getConfiguration
    getPage @config.data['confluence.config.space.key'], @config.data['confluence.config.page.name']
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
