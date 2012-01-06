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
    token = @jira.login @config.get('jira.username'), @config.get('jira.password')
    issue = @jira.getIssue token, id
    pageData['page'] = issue['summary'] if !pageData['page']
    pageData['jiraIssue'] = issue
    customFields = {}
    customFieldValues = issue['customFieldValues']
    allCustomFields = @jira.getCustomFields token
    customFieldValues.each do |customFieldValue|
      customFieldId = customFieldValue['customfieldId']
      allCustomFields.each do |customField|
        customFields[customFieldId] = {
            'name' => customField['name'],
            'value' => customFieldValue['values'].join("\n")
        } if customFieldId == customField['id']
      end
    end
    pageData['customFields'] = customFields
    @jira.logout token
  end

end
