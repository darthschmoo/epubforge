module EpubForge
  module Action
    class Git < Action2
      define_action( "git:save" ) do |action|
        action.help( "commit changes to your project to your repository" )
        action.usage( "'optional commit message'" )
        
        action.execute do
          
        end
      end
      
      
      # 
      # class GitBackup < Action
      #   description "commit your project to the git repo and back it up"
      #   keywords :backup, :save, :commit
      #   usage       "#{$PROGRAM_NAME} commit <project directory (optional if current dir)> \"optional message\""
      # 
      #   desc( "do:save", "save to your git repository")
      #   def do( project, *args )
      #     @project = project
      #     @message = args.length > 0 ? args.last : "incremental backup"
      # 
      #     unless project_already_gitted?
      #       say_error "Not a git-backed project.  Aborting."
      #       say_instruction "Run 'epubforge gitify <project>' to create a backup repository."
      #       return false
      #     end
      # 
      #     `cd #{@project.root_dir} && git commit -a -m "#{@message}" && git push`
      #   end
      # 
      # 
      
      
      
      define_action( "git:init" ) do |action|
        action.help( "create a git repository of the project folder on an external host or thumb drive" )
        
        action.execute do
          @project = project
          @conf = @project.config
          @gitconf = @conf.git
          
          @cli_sequence = CliSequence.new
          @cli_sequence.default( :verbose, true )
          @cli_sequence.default( :local_dir, @project.root_dir )
        
        
          if project_already_gitted?
            say_error "Already seems to be a git project. delete the .git folder if this is incorrect."
            return false
          end

          project_name_with_folder = @gitconf["repo_folder"].fwf_filepath
        
          if @gitconf["remote_host"]
            remote_host = "#{@gitconf['remote_user']}@#{@gitconf['remote_host']}"
            @cli_sequence.default( :remote, remote_host )
            project_url = "ssh://#{remote_host}#{project_name_with_folder}"
        
            @cli_sequence.add_remote_command( "mkdir -p #{project_name_with_folder}", "rm -rf #{project_name_with_folder}" )
            @cli_sequence.add_remote_command( "git --bare init #{project_name_with_folder}" )
            identifier = project_name_with_folder.join( @gitconf["repo_id"] )
            @cli_sequence.add_remote_command( "touch #{identifier}", "rm #{identifier}" )  # undo isn't needed here, since the directory will be wiped out.
          else
            project_url = "file://#{project_name_with_folder}"
            @cli_sequence.add_local_command( "mkdir -p #{project_name_with_folder}", "rm -rf #{project_name_with_folder}" )
            @cli_sequence.add_local_command( "git --bare init #{project_name_with_folder}" )
            identifier = project_name_with_folder.join( @gitconf["repo_id"] )
            @cli_sequence.add_local_command( "touch #{identifier}", "rm #{identifier}" )
          end
  
          # running locally
          @cli_sequence.add_local_command "git init", "rm -rf .git"
          @cli_sequence.add_local_command "git remote add origin #{project_url}"
          @cli_sequence.add_local_command "git add ."
          @cli_sequence.add_local_command "git commit -a -m \"Initial commit\""
          @cli_sequence.add_local_command "git config branch.master.remote origin"
          @cli_sequence.add_local_command "git config branch.master.merge refs/heads/master"
          @cli_sequence.add_local_command "git push origin master"       # need to be explicit about branch the first time

          if @cli_sequence.execute
            say_all_is_well( "All done.  The url for this project is #{project_url}" )
          else
            say_error( "Command sequence failed." )
          end
        end
      end
      
      protected
      def git_remote_exec( cmd )
        say_subtly( "attempting to run remotely:  #{cmd}" )
        `cd #{@project.root_dir} && ssh #{@gitconf["remote_user"]}@#{@gitconf["remote_host"]} "#{cmd}"`
        say( "Success: #{$?.success?}") 
      end
      
      def git_local_exec( cmd )
        say_subtly( "attempting to run locally:  #{cmd}" )
        `cd #{@project.root_dir} && #{cmd}`
        say( "Success: #{$?.success?}")  
      end
    end
  end
end