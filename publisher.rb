require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'
require 'yaml'

class Publisher

  def publish
    modules = Modules.instance
    logger = modules.get :logger
    configurator = modules.get modules.get(:configuration).get 'config.module'
    configurator.getScript configurator.getConfiguration do |configChunk|
      hash = YAML.load configChunk
      pageData = hash['page']
      if pageData
        id = pageData['id']
        if pageData['publish']
          logger.warn "---- publishing #{id} ----"
          pageData['sources'].each do |source|
            id = source['source']
            logger.warn "collecting #{id} source data"
            modules.get(id).gatherData pageData, source['parameters']
          end
          pageData['publications'].each do |publication|
            id = publication['destination']
            logger.warn "publishing data to #{id}"
            dest = modules.get(id)
            params = publication['parameters']
            template = ''
            dest.getScript dest.getTemplate pageData, params do |templateChunk|
              template += templateChunk
            end
            dest.publish Liquid::Template.parse(template).render('data' => pageData), pageData, params
          end
        else
          logger.warn "---- not publishing #{id} ----"
        end
      end
    end
  end

end
