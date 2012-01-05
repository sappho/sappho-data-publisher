require 'Configuration'
require 'soap/wsdlDriver'

class Jira

  def initialize
    @config = Configuration.new
    @jira = SOAP::WSDLDriverFactory.new("#{@config.get 'jira.url'}/rpc/soap/jirasoapservice-v2?wsdl").
        create_rpc_driver
  end

  def gather pageData, parameters
    id = pageData[:id]
    token = @jira.login @config.get('jira.username'), @config.get('jira.password')
    issue = @jira.getIssue token, id
    summary = issue['summary']
    @jira.logout token
    pageData[:page] = summary if !pageData[:page]
  end

end
