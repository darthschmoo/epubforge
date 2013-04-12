# Another trivial change

module EpubForge
  module Action
    class Runner
      include Singleton
      attr_accessor :actions, :actions_directories, :keywords, :htmlizers
            
      def add_actions( *args )
        @keywords ||= {}
        @actions ||= []
        @actions_directories ||= []

        Utils::ActionLoader.require_me( *args )

        new_actions = Utils::ActionLoader.loaded_classes - @actions
        @actions += new_actions
        new_directories = Utils::ActionLoader.loaded_directories - @actions_directories
        @actions_directories += new_directories
        
        for action in new_actions
          for keyword in action.keywords
            @keywords[keyword] = action
          end
        end
      end

      instance.add_actions( EpubForge.root.join( "actions" ) )
      
      # Find all the actions with keywords that start with the given string.
      # If this results in more than one action being found, the proper
      # response is to panic and flail arms.
      def keyword_to_action( keyword )
        exact_match = @keywords.keys.select{ |k| k == keyword }
        
        return [@keywords[exact_match.first]] if exact_match.length == 1
        
        # if no exact match can be found, find a partial match, at the beginning
        # of the keywords.
        @keywords.keys.select{ |k| k.match(/^#{keyword}/) }.map{ |k| @keywords[k] }.uniq
      end
      
      def add_htmlizers( htmlizers_file )
        if htmlizers_file.exist?
          begin
            require htmlizers_file.to_s
          rescue Exception => e
            puts e.message
            puts e.backtrace.map{|line| "\t#{line}" }
            puts "Failed to load htmlizers from project file #{htmlizers_file} Soldiering onward."
          end
        end
      end

      public
      def run( run_description )
        run_description.klass.new.do( run_description.project, *(run_description.args) )
      end
      
      # order:  project_dir(optional), keyword, args
      # If a project_dir is not given, the current working directory is prepended to the arguments list.
      # In some cases -- well, really only 'init', this will be in error.  Because the argument given does
      # not exist yet, it will not recognize the first argument as pointing to a project. 
      def exec( *args )
        # first argument is the action's keyword
        # print help message if no keywords given
        keyword = args.shift || "help"     

        # discover project directory
        project_dir = args[0] ? args[0].epf_filepath.expand : nil      # able to pass in partial/relative filenames
        
        if project_dir && Project.is_project_dir?( project_dir )
          args.shift 
        else
          # see if command is given from inside a project directory.
          project_dir = infer_project_directory
        end 
        

        run_description = RunDescription.new
        
        if project_dir
          project = Project.new( project_dir )
          run_description.project = project
          add_actions( project.settings_folder( "actions" ) )
          add_htmlizers( project.settings_folder( "htmlizers.rb" ) )
        end
        
        run_description.keyword = keyword
        actions = keyword_to_action( keyword )
        
        if actions.length == 1
          run_description.klass = actions.first
          run_description.args = args
          
          if run_description.klass.project_required? && run_description.project.nil?
            puts "No project directory was given, and current working directory is not an epubforge project."
            return false
          end
          
          run( run_description )
        elsif actions.length == 0
          puts "Unrecognized keyword <#{keyword}>.  Quitting."
          false
        else
          puts "Ambiguous keyword <#{keyword}>.  Did you mean...?"
          for action in actions
            puts action.usage
          end
          false
        end
      end
      
      def infer_project_directory
        project_dir = Utils::FilePath.cwd
        Project.is_project_dir?( project_dir ) ? project_dir : nil
      end
    end
  end
end