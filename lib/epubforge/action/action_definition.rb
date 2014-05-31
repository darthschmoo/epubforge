module EpubForge
  module Action
    class ActionDefinition
      # attr_accessor  :default_args, :keyword, :klass, :proc

      get_and_set :help, :usage, :default_args, :keyword, :klass, :proc
      get_and_set_boolean :project_required, :verbose
      
      alias :loader_pattern_registry_key :keyword
      
      def execute( &block )
        proc( block )
      end
      
      def run( *args )
        action = klass.new    # one of the action classes (New or Git or Epub, etc.)
        puts( "Sending args to Action(#{self.keyword}) : #{ 'NO ARGS' if args.fwf_blank? }".paint(:pink) ) if EpubForge.gem_test_mode?
        for arg, i in args.each_with_index
          puts "    #{i}: #{arg.inspect}".paint(:pink) if verbose?
        end
        
        if args.first.is_a?(Project)
          action.project( args.first )
          action.args( args[1..-1] )
        else
          action.args( args )
        end
        
        action.instance_exec( &@proc )
      end
      
      
      def default( name, value )
        (@default_args ||= {})[name] = value
      end

      # def project_required?
      #   @project_required = true if @project_required.nil?
      #   @project_required
      # end
      
      # def verbose?
      #   @verbose == true
      # end
      
      # Most actions require -- nay, demand! -- a project to act upon.
      # Add the line 'project_not_required' to the class definition
      # to keep it from failing out if it can't find an existing project.
      # Used for things like initializing new projects, printing help, 
      # or... my imagination fails me.
      def project_required?
        @project_required = true if @project_required.nil?
        @project_required
      end
      
      
      def project_not_required
        @project_required = false
      end
    end
  end
end