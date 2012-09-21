# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require 'liquid'
require 'sappho-basics/module_register'

module Sappho
  module Data
    module Publisher

      class CustomLiquid

        def CustomLiquid.setup
          Liquid::Template.register_filter(Fullname)
          Liquid::Template.register_tag('squash', Squash)
          Liquid::Template.register_tag('empty', Empty)
        end

        module Fullname

          def fullname username
            begin
              name = Sappho::ApplicationModuleRegister.instance.get('AddressBook').getUserFullName(username)
              raise 'unknown person' unless name and name.length > 0
            rescue
              name = '** John Doe **'
            end
            name
          end

        end

        class Squash < Liquid::Block

          def initialize tag_name, markup, tokens
            super
            @message = (markup ? markup.to_s : '')
            @message = @message.length > 0 ? @message : 'This information has not been supplied.'
          end

          def render context
            wiki = []
            super.each { |line| wiki << line unless line.strip == ''}
            wiki.size > 0 ? wiki.join : @message
          end

        end

        class Empty < Liquid::Block

          def initialize tag_name, markup, tokens
            super
          end

          def render context
            super
            ''
          end

        end

      end

    end
  end
end
