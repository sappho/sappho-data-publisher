# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'sappho-data-publisher/atlassian_app'
require 'xmlrpc/client'

module Sappho
  module Data
    module Publisher

      class Confluence

        def connect
          super do |url|
            XMLRPC::Client.new2("#{url}/rpc/xmlrpc").proxy('confluence1')
          end
        end

        def getGlobalConfiguration
          pageName = @config.data['confluence.global.config.page.name']
          pageName ? getPage(@config.data['confluence.config.space.key'], pageName) : ''
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

        private

        def getPage spaceKey, pageName
          checkLoggedIn
          @logger.info "reading wiki page #{spaceKey}:#{pageName}"
          @appServer.getPage(@token, spaceKey, pageName)['content']
        end

        def setPage spaceKey, parentPageName, pageName, content
          checkLoggedIn
          begin
            page = @appServer.getPage(@token, spaceKey, pageName)
            page['content'] = content
            @logger.info "rewriting existing wiki page #{spaceKey}:#{pageName}"
          rescue
            page = {
              'space' => spaceKey,
              'parentId' => @appServer.getPage(@token, spaceKey, parentPageName)['id'],
              'title' => pageName,
              'content' => content }
            @logger.info "creating new wiki page #{spaceKey}:#{pageName} as child of #{parentPageName}"
          end
          @appServer.storePage @token, page
        end

      end

    end
  end
end
