module EpubForge
  module Action
    module SharedActionInterface
      # def actions_lookup
      #   if self == Action
      #     @actions_lookup ||= ActionsLookup.new
      #   else
      #     Action.actions_lookup
      #   end
      # end
      
      # def register_action_subclass( klass )
      #   if self == Action
      #     @subclasses ||= []
      #     @subclasses = (@subclasses + [klass]).uniq
      #   else
      #     Action.register_action_subclass( klass )
      #   end
      # end
      
      # def subclasses
      #   if self == Action
      #     @subclasses
      #   else
      #     Action.subclasses
      #   end
      # end
      
      # def command_to_action_classes
      #   if self == Action
      #     @command_klass_lookup ||= {}
      #   else
      #     Action.command_to_action_classes
      #   end
      # end
      
      get_and_set( :description )
      # def description( str = nil )
      #   @description = str if str
      #   @description
      # end
      
      # eventually replace description
      def desc( usage, description, options = {} )
        verbose = defined?(EpubForge::Action::Character)  && self == EpubForge::Action::Character
        puts "--------------IN DESC()----------------"   if verbose
        puts self.method_options.inspect                 if verbose
        self.command_to_action_classes[usage] = self
        super( usage, description, options )
        puts self.method_options.inspect                 if verbose
        puts "--------------END DESC()----------------"  if verbose
      end

      # # TODO: Get rid of this
      # def keywords( *args )
      #   if args.fwf_blank?
      #     @keywords ||= []
      #   else 
      #     @keywords = args.map(&:to_s)
      #   end
      #   
      #   @keywords
      # end
      
      # If given one arg, sets keyword
      # if given no args, fetches keyword
      get_and_set( :keyword, :usage )      # 
            # def keyword( k = nil )
            #   @keyword = k unless k.nil?
            #   @keyword
            # end
            # 
            # 
            # def usage( str = nil )
            #   @usage = str if str
            #   @usage
            # end
      
      def project_required?
        @project_required = true if @project_required.nil?
        @project_required
      end
      
      # Most actions require -- nay, demand! -- a project to act upon.
      # Add the line 'project_not_required' to the class definition
      # to keep it from failing out if it can't find an existing project.
      # Used for things like initializing new projects, or... my imagination
      # fails me.
      def project_not_required
        @project_required = false
      end
      
      def include_standard_options
        method_option :verbose, :type => :boolean, :default => false, :aliases => "-v"
        method_option :debug,   :type => :boolean, :default => false, :aliases => "--dbg"
        method_option :help,    :type => :boolean, :default => false, :aliases => "-h"
        method_option :project, :type => :string, :default => nil, :aliases => "--proj"
      end
    end
    
    class Action < Thor
      # def self.inherited( subclass )
      #   self.register_action_subclass( subclass )
      #   subclass.include_standard_options
      # end
      
      include Thor::Actions
      extend SharedActionInterface
            
      CLEAR     = Thor::Shell::Color::CLEAR
      RED       = Thor::Shell::Color::RED
      BLUE      = Thor::Shell::Color::BLUE
      YELLOW    = Thor::Shell::Color::YELLOW
      GREEN     = Thor::Shell::Color::GREEN
      MAGENTA   = Thor::Shell::Color::MAGENTA
      ON_YELLOW = Thor::Shell::Color::ON_YELLOW
      ON_BLUE   = Thor::Shell::Color::ON_BLUE
      
      
      
      
      
      protected      
      def say_when_verbose( *args )
        say( *args ) if @verbose
      end
      
      def say_when_debugging( *args )
        say( *args ) if @debug
      end
      
      def say_error( statement )
        say( "ERROR : #{statement}", RED + ON_BLUE )
      end
      
      def say_instruction( statement )
        say( statement, YELLOW )
      end
      
      def say_all_is_well( statement )
        say( statement, GREEN )
      end
      
      def say_subtly( statement )
        say( statement, MAGENTA )
      end
      
      def yes_prettily?( statement )
        yes?( statement, BLUE )
      end
      
      
      
      # choices = Array of Arrays(length:2) or Strings.  Can be intermingled freely.
      # when the user selects a string, returns the string.  For the array,
      # the user sees the first item, and the programmer gets back the last item
      def ask_from_menu( statement, choices )
        choices.map! do |choice|
          choice.is_a?(String) ? [choice] : choice    # I'm being too clever by half here.  .first/.last still works.
        end
        
        choice_text = ""
        choices.each_with_index do |choice,i|
          choice_text << "\t\t#{i}) #{choice.first}\n" 
        end
        
        selection = ask( "#{statement}\n\tChoices:\n#{choice_text}>>> ", BLUE )
        choices[selection.to_i].last
      end
      
      def ask_prettily( statement )
        ask( statement, BLUE )
      end


      
      # hope this doesn't break anything.  Sure enough, it broke a lot of things.
      # def destination_root=( root )
      #   @destination_stack ||= []
      #   @destination_stack << (root ? root.fwf_filepath.expand : '')
      # end

      def executable_installed?( name )
        name = name.to_sym
        
        if @executables.nil?
          @executables = {}
          for exe, path in (EpubForge.config[:exe_paths] || {})
            @executables[exe] = path.fwf_filepath
          end
        end
        
        @executables[name] ||= begin
          _which = `which #{name}`.strip
          (_which.length == 0) ? false : _which.fwf_filepath
        end
          
        @executables[name]  
      end
      
      def requirements
        @requirements ||= []
      end
      
      def add_requirement( *args, &block )
        @requirements ||= []
        @requirements.push( [args, block] )
      end
      
      def requires_executable( ex, fail_msg )
        add_requirement( ex, fail_msg ) do
          executable_installed?( ex, fail_msg )
        end
      end
      
      def must_target_a_project( project_dir )
        add_requirement( project_dir ) do
          Project.is_project_dir?( project_dir )
        end
      end
      
      def git_installed?
        executable_installed?('git')
      end
      
      def ebook_convert_installed?
        executable_installed?('ebook-convert')
      end
      
      def project_already_gitted?
        @project.root_dir.join( ".git" ).directory?
      end
      
      def quit_with_error( msg, errno = -1 )
        STDERR.write( "\n#{msg}\n")
        exit( errno )
      end
      
      def before_start
        variablize_options( :project, :debug, :help, :verbose )
                # @project = @options[:project]
                # @debug   = @options[:debug]
                # @help    = @options[:help]
                # @verbose = @options[:verbose]
        @project = Project.new( @project ) unless @project.nil?
      end
      
      # takes a series of symbols or an array of symbols
      # for each symbol, creates an instance var from @options[:symbol]
      def variablize_options( *symbols )
        symbols.flatten!  # in case someone passes an array
        for sym in symbols
          self.instance_variable_set( :"@#{sym}", @options[sym] )
        end
      end
    end
  end
end