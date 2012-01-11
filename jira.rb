require 'Dependencies'
require 'soap/wsdlDriver'

class Jira

  def initialize
    config = Dependencies.instance.get :configuration
    @logger = Dependencies.instance.get :logger
    url = config.get 'jira.url'
    @jira = SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").create_rpc_driver
    @token = @jira.login config.get('jira.username'), config.get('jira.password')
    @allCustomFields = @jira.getCustomFields @token
    @logger.report "Jira #{url} is online"
  end

  def gatherData pageData, parameters
    id = pageData['id']
    paramId = parameters['id']
    id = paramId if paramId
    issue = @jira.getIssue @token, id
    pageData['pageName'] = issue['summary'] if !pageData['pageName']
    pageData['jiraIssue'] = issue
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
