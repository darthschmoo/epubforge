# Another trivial change

module EpubForge
  module Action
    # Directory containing action files
    class Directory < Utils::FilePath
      def glob( *args )
        args = [ "**", "*.rb" ] if args.length == 0
        Dir.glob( self.join( *args ) ).map{ |f| ActionLoader.new(f) }
      end
    end
    
    # filepath string with metadata, representing an action 
    # file that can be loaded.
    
    class ActionLoader < Utils::FilePath
      def class_name
        base = self.basename.split('.')[0].camelize
        "EpubForge::Action::#{base}"
      end
      
      def require_action
        require self
        raise NameError.new("could not find #{class_name}") unless self.class_loaded?( self.class_name )
      end
      
      def class_loaded?( class_name )
        begin
          self.to_class
          return true
        rescue NameError
          return false
        end
      end
      
      def to_class
        eval self.class_name
      end
    end
    
    class Runner
      include Singleton
      attr_accessor :actions, :action_directories, :keywords
      
      def self.actions_directories
        @actions_directories ||= [ Directory.new( EpubForge.root.join( "lib", "actions" ) ) ]
        
        @actions_directories
      end
      
      def add_actions_directory( dir )
        dir = Directory.new( dir )
        if dir.exist?
          @actions_directories << dir
          add_actions_from_onedirectory( dir )
        end
      end

      def add_actions_from_one_directory( dir )
        new_files = dir.glob
        @actions_class_files ||= []
        @actions ||= []
        @keywords ||= {}
        @actions_class_files += new_files

        for action_loader in new_files
          action_loader.require_action
          @actions << action_loader.to_class
          
          for keyword in action_loader.to_class.keywords
            @keywords[keyword] = action_loader.to_class
          end
        end
      end
      
      # Find all the actions with keywords that start with the given string.
      # If this results in more than one action being found, the proper
      # response is to panic and flail arms.
      def keyword_to_action( keyword )
        @keywords.keys.select{ |k| k.match(/^#{keyword}/) }.map{|k| @keywords[k]}.uniq
      end

      def initialize
        for folder in self.class.actions_directories
          self.add_actions_from_one_directory( folder )
        end
      end
    
      def run( run_description )
        run_description.klass.new.do( run_description.project, run_description.args )
      end
      
      # order:  project_dir(optional), keyword, args
      # If a project_dir is not given, the current working directory is prepended to the arguments list.
      # In some cases -- well, really only 'init', this will be in error.  Because the argument given does
      # not exist yet, it will not recognize the first argument as pointing to a project. 
      def execute_args( args )
        # first argument is the action's keyword
        # print help message if no keywords given
        keyword = args.shift || "help"     

        # discover project directory

        project_dir = args[0] ? args[0].epf_filepath.expand : nil      # able to pass in partial/relative filenames
        
        if project_dir && Project.is_project_dir?( project_dir )
          args.pop 
        else
          # see if command is given from inside a project directory.
          project_dir = Utils::FilePath.cwd
          if Project.is_project_dir?( project_dir )
            # any project-specific actions to load?
            self.add_actions_directory( project_dir.join( "actions" ) )
          else
            # no project dir given
            project_dir = nil
          end
        end    

        run_description = RunDescription.new
        run_description.project = Project.new( project_dir ) if project_dir
        run_description.keyword = keyword
        actions = keyword_to_action( keyword )

        if actions.length == 1
          run_description.klass = actions.first
          run_description.args = args
          
          run( run_description )

        elsif actions.length == 0
          puts "Unrecognized keyword <#{keyword}>.  Quitting."
        else
          puts "Ambiguous keyword <#{keyword}>.  Did you mean...?"
          for action in actions
            puts action.usage
          end
        end

      end
    end
  end
end