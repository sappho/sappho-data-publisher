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
    @logger.warn "Jira #{url} is online"
    @users = {}
  end

  def gatherData pageData, parameters
    id = parameters['id']
    @logger.warn "reading Jira issue #{id}"
    issue = @jira.getIssue @token, id
    summary = issue['summary']
    pageData['summary'] = summary
    pageData['pagename'] = summary unless pageData['pagename']
    pageData['description'] = issue['description']
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

  def getUser username
    user = @users[username]
    return user if user
    @logger.warn "reading Jira user details for #{username}"
    @users[username] = @jira.getUser @token, username
  end

  def shutdown
    @jira.logout @token
    @logger.warn 'disconnected from Jira'
  end

end
