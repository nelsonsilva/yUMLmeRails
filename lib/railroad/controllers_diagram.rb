# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

require 'railroad/app_diagram'

# RailRoad controllers diagram
class ControllersDiagram < AppDiagram
 
  def initialize(options)
    #options.exclude.map! {|e| "app/controllers/" + e}
    super options
    @graph.diagram_type = 'Controllers'
  end

  # Process controller files
  def generate
    STDERR.print "Generating controllers diagram\n" if @options.verbose

    files = Dir.glob("app/controllers/**/*_controller.rb") - @options.exclude
    files << 'app/controllers/application.rb'
    files.each do |f|
      class_name = extract_class_name(f)
      # ApplicationController's file is 'application.rb'
      class_name += 'Controller' if class_name == 'Application'
      process_class class_name.constantize
    end 
  end # generate

  private

  # Load controller classes
  def load_classes
    begin
      disable_stdout
      # ApplicationController must be loaded first
      require "app/controllers/application.rb" 
      files = Dir.glob("app/controllers/**/*_controller.rb") - @options.exclude
      files.each {|c| require c }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "controller classes"
      raise
    end
  end # load_classes

  # Proccess a controller class
  def process_class(current_class)

    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose

    if @options.brief
      @graph.add_node ['controller-brief', current_class.name]
    elsif current_class.is_a? Class 
      # Collect controller's methods
      node_attribs = {:public    => [], 
                      :protected => [], 
                      :private   => []}
      current_class.public_instance_methods(false).sort.each { |m|
        node_attribs[:public] << m
      } unless @options.hide_public
      current_class.protected_instance_methods(false).sort.each { |m|
        node_attribs[:protected] << m
      } unless @options.hide_protected
      current_class.private_instance_methods(false).sort.each { |m|
        node_attribs[:private] << m 
      } unless @options.hide_private
      @graph.add_node ['controller', current_class.name, node_attribs]
    elsif @options.modules && current_class.is_a?(Module)
      @graph.add_node ['module', current_class.name]
    end

    # Generate the inheritance edge (only for ApplicationControllers)
    if @options.inheritance && 
       (ApplicationController.subclasses.include? current_class.name)
      @graph.add_edge ['is-a', current_class.superclass.name, current_class.name]
    end
  end # process_class

end # class ControllersDiagram
