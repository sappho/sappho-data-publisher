require 'Configuration'
require 'soap/wsdlDriver'

class Jira

  def initialize
    @config = Configuration.new
    @jira = SOAP::WSDLDriverFactory.new("#{@config.get 'jira.url'}/rpc/soap/jirasoapservice-v2?wsdl").
        create_rpc_driver
  end

  def gather pageData, parameters
    id = pageData['id']
    paramId = parameters['id']
    id = paramId if paramId
    token = @jira.login @config.get('jira.username'), @config.get('jira.password')
    issue = @jira.getIssue token, id
    pageData['pageName'] = issue['summary'] if !pageData['pageName']
    pageData['jiraIssue'] = issue
    customFields = {}
    customFieldValues = issue['customFieldValues']
    allCustomFields = @jira.getCustomFields token
    customFieldValues.each do |customFieldValue|
      customFieldId = customFieldValue['customfieldId']
      customFields[customFieldId] = {
          'name' => allCustomFields.find{|customField| customFieldId == customField['id']}['name'],
          'values' => customFieldValue['values']
      }
    end
    pageData['customFields'] = customFields
    @jira.logout token
  end

end
