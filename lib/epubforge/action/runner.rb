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
      end
      
      def run
        @run_description.run
        @run_description
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
        
        run
      end
    
    

      protected
      def parse_args
        @args << "help" if @args.fwf_blank?
        @run_description = RunDescription.new
        
        # map_command_to_action                                 # if it's one of the default actions
        fetch_project
        load_project_machinery

        map_command_to_action # unless @run_description.action  # check for project-specific actions
        
        @run_description.quit_on_errors
        
        
        
        return false unless @run_description.action

        if @run_description.project.nil? && @run_description.action.project_required?
          @run_description.errors << "Could not find a project directory (current directory not a project, no project given as an argument), but the action #{@run_description.action} requires one."
        else
          @run_description.args = @args
        end
      end
      
      # TODO:  Need to determine if the project is there, and if it's needed, then load all the
      # actions at once.  
      def map_command_to_action
        @run_description.action = Action2[ @args.first ]
        if @run_description.action.nil?
          @run_description.errors << "Unrecognized keyword <#{@args.first}>.  Quitting."
        end
      end
      
      
      # The priority for the project directory
      # 1) explicitly stated directory  --project=/home/andersbr/writ/fic/new_project
      # 2) the arg immediately after the command:subcommand:subsubcommand arg
      # 3) the current working directory (if it's an existing project)
      #
      # As a side-effect, replaces implicit directories with an explicit --project flag as the final argument
      # because Thor seems to like explicit flags.  Though I'm moving away from Thor.  
      def fetch_project
        project_dir =   fetch_project_by_project_flag
        project_dir ||= fetch_project_by_second_arg
        project_dir ||= fetch_project_by_current_dir

        if project_dir
          @run_description.project = Project.new( project_dir )
          @args.push( "--project=#{project_dir}" )
        end
      end
      
      def fetch_project_by_project_flag
        project_dir = nil
        project_flag_regex = /^--proj(ect)?=/
        @args.each_with_index do |arg, i|
          if arg.is_a?(String) && arg =~ project_flag_regex
            project_dir = arg.gsub( project_flag_regex, "" ).epf_remove_surrounding_quotes.fwf_filepath.expand
            if Project.is_project_dir?( project_dir )
              @args.delete_at(i)
            else
              @run_description.errors << "Project given by flag --project= is not a valid project directory."
            end
          end
        end
        
        project_dir
      end
      
      def fetch_project_by_second_arg
        if Project.is_project_dir?( @args[1] )
          return @args.delete_at(1)
        else
          return nil
        end
      end
      
      def fetch_project_by_current_dir
        cwd = FunWith::Files::FilePath.cwd
        project_dir = (Project.is_project_dir?( cwd ) ? cwd : nil)
      end
      
      def print_help
      end
      
      def load_project_machinery
        if proj = @run_description.project
          Action2.loader_pattern_load_from_dir( proj.settings_folder( "actions" ) )
          Utils::HtmlTranslator.loader_pattern_load_from_dir( proj.settings_folder( "html_translators" ) )
          Utils::Converter.loader_pattern_load_from_dir( proj.settings_folder( "converters" ) )
        end
      end
    end
  end
end