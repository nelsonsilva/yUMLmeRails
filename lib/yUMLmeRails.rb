APP_NAME       = "railroad"
APP_HUMAN_NAME = "RailRoad"
APP_VERSION    = [0,5,0]
COPYRIGHT      = "Copyright (C) 2007-2008 Javier Smaldone"

require 'ostruct'
require 'railroad/models_diagram'
#require 'railroad/controllers_diagram'
#require 'railroad/aasm_diagram'

class YUMLmeRails
    class << self
    def generate_diagram
         options = OpenStruct.new(
            :all => true,
            :brief => false,
            :exclude => [],
            :inheritance => false,
            :join => false,
            :label => false,
            :modules => false,
            :hide_magic => false,
            :hide_types => false,
            :hide_public => false,
            :hide_protected => false,
            :hide_private => false,
            :plugins_models => false,
            :root => '',
            :transitive => true,
            :verbose => false,
            :xmi => false,
            :yuml => true,
            :command => 'models'
        )


        if options.command == 'models'
          diagram = ModelsDiagram.new options
        #elsif options.command == 'controllers'
        #  diagram = ControllersDiagram.new options
        #elsif options.command == 'aasm'
        #  diagram = AasmDiagram.new options
        end

        diagram.generate
        diagram.graph.to_yuml
    end
    end
end
