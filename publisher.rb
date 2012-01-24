require 'rubygems'
require 'modules'
gem 'liquid'
require 'liquid'
require 'yaml'

class Publisher

  def publish
    modules = Modules.instance
    logger = modules.get :logger
    configurator = modules.get modules.get(:configuration).data['config.module']
    globalScript = ''
    configurator.getScript(configurator.getGlobalConfiguration) { |configChunk| globalScript += configChunk }
    configurator.getScript configurator.getConfiguration do |configChunk|
      allData = YAML.load(globalScript + configChunk)
      pageData = allData['page']
      if pageData
        logger.info "---- publishing #{pageData['id']} ----"
        pageData['sources'].each do |source|
          id = source['source']
          logger.info "collecting #{id} source data"
          modules.get(id).gatherData pageData, source['parameters']
        end
        pageData['publications'].each do |publication|
          id = publication['destination']
          logger.info "publishing data to #{id}"
          dest = modules.get(id)
          params = publication['parameters']
          template = ''
          dest.getScript(dest.getTemplate pageData, params) { |templateChunk| template += templateChunk }
          dest.publish Liquid::Template.parse(template).render('data' => pageData), pageData, params
        end
      end
    end
  end

end
