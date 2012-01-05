require 'Configuration'
require 'soap/wsdlDriver'

class ConfluenceWiki

  def initialize
    @config = Configuration.new
    @wiki = SOAP::WSDLDriverFactory.new("#{@config.get 'confluence.url'}/rpc/soap-axis/confluenceservice-v1?wsdl").
        create_rpc_driver
  end

  def getPage spaceKey, pageName
    token = @wiki.login @config.get('confluence.username'), @config.get('confluence.password')
    content = @wiki.getPage(token, spaceKey, pageName)['content']
    @wiki.logout token
    content
  end

end
