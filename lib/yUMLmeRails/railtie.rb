require 'yUMLmeRails'
require 'rails'

module YUMLmeRails
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/yUMLmeRails.rake"
    end
  end
end
