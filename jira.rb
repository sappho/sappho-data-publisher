require 'modules'
require 'soap/wsdlDriver'

class Jira

  def initialize
    config = Modules.instance.get :configuration
    @logger = Modules.instance.get :logger
    url = config.get 'jira.url'
    @jira = SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
    @token = @jira.login config.get('jira.username'), config.get('jira.password')
    @allCustomFields = @jira.getCustomFields @token
    @logger.report "Jira #{url} is online"
  end

  def gatherData pageData, parameters
    id = parameters['id']
    @logger.report "reading Jira issue #{id}"
    issue = @jira.getIssue @token, id
    pageData['pagename'] = issue['summary'] unless pageData['pagename']
    customFields = {}
    customFieldValues = issue['customFieldValues']
    customFieldValues.each do |customFieldValue|
      customFieldId = customFieldValue['customfieldId']
      customFields[customFieldId] = {
          'name' => @allCustomFields.find{|customField| customFieldId == customField['id']}['name'],
          'values' => customFieldValue['values']
      }
    end
    pageData['customFields'] = customFields
  end

  def shutdown
    @jira.logout @token
    @logger.report 'disconnected from Jira'
  end

end
