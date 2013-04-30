# Another trivial change

module EpubForge
  module Action
    class Runner
      attr_accessor :actions_lookup
      def initialize
        reset
      end
      
      def reset
        @args = []
        @run_description = RunDescription.new
        @actions_lookup = ActionsLookup.new
        @actions_lookup.add_actions( EpubForge::ACTIONS_DIR )
        @actions_lookup.add_actions( EpubForge::USER_ACTIONS_DIR ) if EpubForge::USER_ACTIONS_DIR.directory?
      end
            
      def run
        if @run_description.runnable?
          @run_description.klass.new.do( @run_description.project, *(@run_description.args) )
        else
          puts "Error(s) trying to complete the requested action:"
          puts @run_description.errors.join("\n")
        end
      end
      
      # order:  project_dir(optional), keyword, args
      # If a project_dir is not given, the current working directory is prepended to the arguments list.
      # In some cases -- well, really only 'init', this will be in error.  Because the argument given does
      # not exist yet, it will not recognize the first argument as pointing to a project. 
      def exec( *args )
        # remove project from arguments
        @args = args
        # first argument is the action's keyword
        # print help message if no keywords given
        parse_args
        
        # finish setting up run_description
        @run_description.args = @args
        
        run
      end
    
    
      # The priority for the project directory
      # 1) explicitly stated directory  --project=/home/andersbr/writ/fic/new_project
      # 2) the current working directory (if it's an existing project)
      # 3) the final arg
      #
      # At this point, 
      protected
      def parse_args
        @run_description = RunDescription.new
        @run_description.keyword = @args.shift || "help"
        
        existing_project = false
        project_dir = get_explicit_project_option( @args )
        
        # see if the last argument is a project directory
        unless project_dir || @args.length == 0
          last_arg = @args.pop
          unless project_dir = ( Project.is_project_dir?( last_arg ) )
            @args.push( last_arg )
          end
        end
        
        # see if current working directory is a project directory
        unless project_dir 
          cwd = FunWith::Files::FilePath.cwd
          if Project.is_project_dir?( cwd )
            project_dir = cwd
          end
        end
        
        # At this point, if we're going to find an existing project directory, we'll have found it by now.
        # Time to load the actions and determine whether the keyword matches an existing action
        if project_dir && Project.is_project_dir?( project_dir )
          existing_project = true
          @run_description.project = Project.new( project_dir )
          @actions_lookup.add_actions( @run_description.project.settings_folder( "actions" ) )
          Utils::Htmlizer.instance.add_htmlizers( @run_description.project.settings_folder( "htmlizers.rb" ) )
        end
        
        map_keyword_to_action
        
        if !existing_project && @run_description.klass.project_required?
          @run_description.errors << "Could not find a project directory, but the action #{@run_description.klass} requires one. Current directory is not an epubforge project."
        end
      end
      
      def map_keyword_to_action
        actions = actions_lookup.keyword_to_action( @run_description.keyword )

        if actions.length == 1
          @run_description.klass = actions.first
        elsif actions.length == 0
          @run_description.errors << "Unrecognized keyword <#{keyword}>.  Quitting."
          false
        else
          @run_description.errors << "Ambiguous keyword <#{keyword}>.  Did you mean...?\n#{actions.map(&:usage).join('\n')}"
          false
        end
      end
      
      def get_explicit_project_option( args )
        proj_opt_regex = /^--project=/
        
        proj_opt = args.find do |arg|
          arg.is_a?(String) && arg.match( proj_opt_regex )
        end
      
        if proj_opt
          args.delete( proj_opt )
          proj_opt.gsub( proj_opt, '' ).fwf_filepath
        else
          false
        end
      end
    end
  end
end