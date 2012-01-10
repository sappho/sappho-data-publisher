require 'singleton'
require 'Dependencies'
require 'soap/wsdlDriver'

class Jira

  include Singleton

  def initialize
    config = Dependencies.instance.modules[:configuration]
    url = config.get 'jira.url'
    @jira = SOAP::WSDLDriverFactory.new("#{url}/rpc/soap/jirasoapservice-v2?wsdl").
        create_rpc_driver
    @token = @jira.login config.get('jira.username'), config.get('jira.password')
    @allCustomFields = @jira.getCustomFields @token
    Dependencies.instance.modules[:logger].report "Jira #{url} is online"
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

  def logout
    @jira.logout @token
  end

end
