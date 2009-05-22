# UML dumper
# Generates an XMI db/schema.xml file describing the current DB as seen by ActiveRecord. 
# Produces XMI 1.1 for UML 1.3 Rose Extended, viewable e.g. by StarUML
#
# Author: Miroslav Skultety, 2006
#
module ActiveRecord
  # This class is used to dump the database schema for some connection to some
  # output format (e.g. XMI UML).
  class UmlDumper #:nodoc:
    private_class_method :new
    
    # A list of tables which should not be dumped to the schema. 
    # Acceptable values are strings as well as regexp.
    # This setting is only used if ActiveRecord::Base.schema_format == :ruby
    cattr_accessor :ignore_tables 
    @@ignore_tables = []

    def self.dump(connection=ActiveRecord::Base.connection, stream=STDOUT)
      new(connection).dump(stream)
      stream
    end

    def dump(stream)
      print_header(stream)

      tables = find_tables
      assocs = find_assocs(tables)
      
      dump_tables(stream,tables,assocs)
      dump_assocs(stream,assocs)

      print_intermezzo(stream)

      dump_types(stream)
      dump_diags(stream)

      print_trailer(stream)

      return stream
    end

    private

      def initialize(connection)
        @connection = connection
        @types = @connection.native_database_types

        @last_id = 17   # to generate unique XMI.ID
        @last_table = 0 # to generate table view positions
        @table_views = {}  # used to draw tables and associations
        @assoc_views = []  # used to draw associations
        @virtabs = []   # virtual tables
        @xmitps = {}    # data types used in this XMI document
      end
      
      def find_tables
        # first collect all valid table names
        table_names = []
        @connection.tables.sort.each do |tbl|
          next if ["schema_info", ignore_tables].flatten.any? do |ignored|
            case ignored
            when String: tbl == ignored
            when Regexp: tbl =~ ignored
            else
              raise StandardError, 'ActiveRecord::UmlDumper.ignore_tables accepts an array of String and / or Regexp values.'
            end
          end 
          table_names << tbl
        end       
        return table_names
      end
      
      def find_assocs(table_names)
        
        # find each table's associations
        associations = table_names.inject({:rels=>[],:ends=>{}}) do |assocs, tbl|
          find_rels(tbl,table_names,assocs)
        end       
        return associations
      end
      
      def find_rels(table,table_names,association_pool)
        columns = @connection.columns(table)
        columns.each do |column|
          raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
          if (column.name =~ /(.+)_id$/) and (column.type.to_s=="integer")
            foreign_table=$1.pluralize
            end1n = new_xmi_id
            end2n = new_xmi_id
            association_pool[:rels] << {:assocn => new_xmi_id, 
                                        :end1n => end1n, 
                                        :end2n => end2n, 
                                        :table => table, 
                                        :foreign_table => foreign_table}
            assoc_ends = association_pool[:ends]
            assoc_ends[table] ||= []
            assoc_ends[table] << end1n
            assoc_ends[foreign_table] ||= []
            assoc_ends[foreign_table] << end2n
            if not table_names.include?(foreign_table)
              @virtabs << foreign_table if not @virtabs.include? foreign_table
            end
          end
        end      
        return association_pool
      end

      def find_columns(table)
        result = []
        @connection.columns(table).each do |column|
          raise StandardError, "Unknown type '#{column.sql_type}' for column '#{column.name}'" if @types[column.type].nil?
          typnm = column.type.to_s
          typnm = typnm + "("+column.limit.to_s+")" if column.limit != @types[column.type][:limit] 
          typid = @xmitps[typnm]
          if !typid 
            typid = @xmitps[typnm] = new_xmi_id
          end
          result << { :id => new_xmi_id.to_s, 
                      :name => column.name.to_s, 
                      :type => typid.to_s }
        end
        return result
      end
 # ====================================================================================================================
      def dump_tables(stream,table_names,assocs)
        # process each DB table
        table_names.each do |tbl|
          dump_table(stream, tbl, assocs)
        end     
        # and also process virtual tables
        @virtabs.each do |tbl|
          dump_table(stream, tbl, assocs, true)
        end       
      end
      
      def dump_table(stream, table, assocs, virtual=false)
        begin
          tabnum = new_xmi_id.to_s 
          xpos, ypos = new_table_position
          attrs = virtual ? [] : find_columns(table)          
          print_table(stream, table,tabnum,assocs[:ends][table],attrs)
          @table_views[table] = { :tabnum => tabnum, 
                                  :vnum => new_xmi_id.to_s, 
                                  :xpos => xpos, 
                                  :ypos => ypos, 
                                  :virtual => virtual} # to be used for drawing
        rescue => e
          stream.puts "# Could not dump table #{table.inspect} because of following #{e.class}"
          stream.puts "#   #{e.message}"
          stream.puts "#   #{e.backtrace}"
          stream.puts
        end
        stream
      end
      
      def dump_assocs(stream,assocs)
        assocs[:rels].each do |relation| # assocn, end1n, end2n, table, foreign_table
          fromtab = @table_views[relation[:table]]
          totab = @table_views[relation[:foreign_table]]
          print_assoc(stream,
                      relation[:assocn].to_s, 
                      relation[:end1n].to_s, 
                      relation[:end2n].to_s, 
                      fromtab[:tabnum].to_s, 
                      totab[:tabnum].to_s)
          x1 = fromtab[:xpos]
          y1 = fromtab[:ypos]
          x2 = totab[:xpos]
          y2 = totab[:ypos]
          @assoc_views << { :vnum => new_xmi_id.to_s, 
                            :xpos => ((x1+x2)/2).to_s, 
                            :ypos => ((y1+y2)/2).to_s, 
                            :wids => (x2-x1).abs.to_s, 
                            :hite => (y2-y1).abs.to_s, 
                            :asn => relation[:assocn].to_s }
        end
      end
      
      def dump_types(stream)
        @xmitps.each do |type_name, type_id|
          print_type(stream,type_id,type_name)
        end
        print_types_end(stream)
      end
      
      def dump_diags(stream)
          print_diags_start(stream)
          @table_views.each do |table,params|
            print_table_view(stream, params)
          end
          @assoc_views.each do |params|
            print_assoc_view(stream, params)
          end
          print_diags_end(stream)
      end
# ====================================================================================================================
      def new_xmi_id
        @last_id+=1
      end
      
      def new_table_position
        xpos = ((@last_table*2)%7) * 200 + 100
        ypos = ((@last_table*2)/7) * 200 + 100
        @last_table+=1
        return [xpos,ypos]
      end
# ====================================================================================================================      
      def print_header(stream)
        stream.puts <<HEADER
<?xml version = "1.0" encoding = "UTF-8"?>
<XMI xmi.version = "1.1" xmlns:UML="href://org.omg/UML/1.3">
<XMI.header>
  <XMI.documentation>
    <XMI.owner></XMI.owner>
    <XMI.contact></XMI.contact>
    <XMI.exporter>RubyOnRails.UML_dumper</XMI.exporter>
    <XMI.exporterVersion>1.0</XMI.exporterVersion>
    <XMI.notice></XMI.notice>
  </XMI.documentation>
  <XMI.metamodel xmi.name = "UML" xmi.version = "1.3"/>
 </XMI.header>
<XMI.content>
<UML:Model xmi.id="UMLProject.1" name=#{@connection.current_database.inspect}>
  <UML:Namespace.ownedElement>
    <UML:Model xmi.id="UMLModel.6" name="Design Model">
      <UML:Namespace.ownedElement>
HEADER
#/
      end

      def print_intermezzo(stream)
        stream.puts <<INTERM
        <UML:Stereotype xmi.id="X.14" name="designModel" extendedElement="UMLModel.6"/>
      </UML:Namespace.ownedElement>
    </UML:Model>
INTERM
      end
      
      def print_trailer(stream)
        stream.puts <<FOOTR
</UML:Diagram>
</XMI.content>
</XMI>
FOOTR
# /
      end
      
      def print_table(stream, table,tabnum,ends,attrs=nil)
        stream.print '        <UML:Class xmi.id="UMLClass.'+tabnum+'" name='+table.inspect+' participant="'
        if ends
          stream.print ends.collect{ |assend| "UMLAssociationEnd."+assend.to_s }.join(" ") 
        end
        if attrs.blank?
          stream.puts '"/>'
        else
          stream.puts '">'
          stream.puts "          <UML:Classifier.feature>"
          attrs.each do |attr|
            stream.print "            <UML:Attribute xmi.id='UMLAttribute.#{attr[:id]}' name='#{attr[:name]}' type='X.#{attr[:type]}'/>\n"
          end
          stream.puts "          </UML:Classifier.feature>"
          stream.puts "        </UML:Class>"
        end
      end

      def print_table_view(stream, params)
        stream.print "    <UML:DiagramElement xmi.id=\"UMLClassView.#{params[:vnum]}\" geometry=\"#{params[:xpos].to_s}, #{params[:ypos].to_s}, 20, 20\" style=\""
        if params[:virtual]
          stream.print "LineColor.Red=28,LineColor.Green=28,LineColor.Blue=28,FillColor.Red=185,FillColor.Green=185,FillColor.Blue=185,"
        end
        stream.puts "AutomaticResize=1\" subject=\"UMLClass.#{params[:tabnum]}\"/>"
      end

      def print_assoc(stream,asn,e1n,e2n,t1,t2)
        stream.puts <<ASSOCS
                <UML:Association xmi.id="UMLAssociation.#{asn}">
                  <UML:Association.connection>
                    <UML:AssociationEnd xmi.id="UMLAssociationEnd.#{e1n}" type="UMLClass.#{t1}"/>
                    <UML:AssociationEnd xmi.id="UMLAssociationEnd.#{e2n}" isNavigable="false" type="UMLClass.#{t2}"/>
                  </UML:Association.connection>
                </UML:Association>
ASSOCS
      end
      
      def print_assoc_view(stream, params) 
        stream.puts <<DIAGASS
    <UML:DiagramElement xmi.id="UMLAssociationView.#{params[:vnum]}" geometry="#{params[:xpos]}, #{params[:ypos]}, #{params[:wids]}, #{params[:hite]}" subject="UMLAssociation.#{params[:asn]}"/>
DIAGASS
      end

      def print_diags_start(stream) 
        stream.puts "  <UML:Diagram.element>"
      end

      def print_diags_end(stream) 
        stream.puts "  </UML:Diagram.element>"
      end
      
      def print_type(stream,type_id,type_name) 
        stream.puts "    <UML:DataType xmi.id='X.#{type_id}' name='#{type_name}'/>"
      end
      
      def print_types_end(stream)
        stream.puts <<AFTERTYPES
  </UML:Namespace.ownedElement>
</UML:Model>
<UML:Diagram xmi.id="UMLClassDiagram.7" name="Main" diagramType="ClassDiagram" toolName="Rational Rose 98" owner="UMLModel.6">
AFTERTYPES
      end
  end
end
