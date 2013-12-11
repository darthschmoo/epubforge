module EpubForge
  module Action
    class LocalAction < ThorAction
      TEMPLATE = EpubForge.root( "templates", "default", "settings", "actions", "local_action.rb.example" )
      
      method_option :desc, :type => :string, :default => "Describe this module"
      method_option :actions, :type => :string, :default => "do"
      method_option :template, :type => :string, :default => TEMPLATE
      method_option :outfile, :type => :string
      
      desc( "action:local:add", "description" )
      def add( *args )
        before_start

        command_name = @args.shift       # Will either be a CamelCase (making a class) or a downcased
        class_name ||= "ExampleAction"
        actions = @actions.split(",").map(&:strip)
        slug = class_name.epf_decamelize
        template = @template
        outfile = (@outfile || @project.settings_folder.join( "actions", "#{slug}.rb" )).fwf_filepath
        
        if outfile.file?
          puts "File already exists: #{outfile}"
          exit(-1)
        end
        
        with_locals( { :desc => @desc, :class_name => class_name, :slug => slug, :actions => actions } ) do
          erb = ERB.new( template.read )
          result = erb.result(binding)
          
          outfile.write( result )
        end
      end
      
      protected
      def before_start
        super()
        @desc = @options[:desc]
        @actions = @options[:actions]
        @template = @options[:template]
        @outfile = @options[:outfile]
      end
    end
  end
end
