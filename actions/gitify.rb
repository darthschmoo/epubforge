module EpubForge
  module Action
    class Gitify < ThorAction
      description "create a remote git repository of the project folder"
      keywords    :gitify, :git_init
      usage       "#{$PROGRAM_NAME} gitify <project_directory>"
      
      desc( "do:gitify", "create a git repository to hold backups" )
      def do( project, *args )
        @project = project
        @conf = @project.config
        @gitconf = @conf["git"]
        @cli_sequence = CliSequence.new
        @cli_sequence.default( :verbose, true )
        @cli_sequence.default( :local_dir, @project.target_dir )
        
        
        if project_already_gitted?
          say_error "Already seems to be a git project. delete the .git folder if this is incorrect."
          return false
        end

        project_name_with_folder = @gitconf["repo_folder"].epf_filepath.expand
        
        if @gitconf["remote_host"]
          remote_host = "#{@gitconf['remote_user']}@#{@gitconf['remote_host']}"
          @cli_sequence.default( :remote, remote_host )
          project_url = "ssh://#{remote_host}#{project_name_with_folder}"
        
          # git_remote_exec( "mkdir -p #{project_name_with_folder}" )
          @cli_sequence.add_remote_command( "mkdir -p #{project_name_with_folder}", "rm -rf #{project_name_with_folder}" )
          # git_remote_exec( "git --bare init #{project_name_with_folder}" )
          @cli_sequence.add_remote_command( "git --bare init #{project_name_with_folder}" )
          # git_remote_exec( "touch #{project_name_with_folder.join( @gitconf["repo_id"] )}")
          identifier = project_name_with_folder.join( @gitconf["repo_id"] )
          @cli_sequence.add_remote_command( "touch #{identifier}", "rm #{identifier}" )  # undo isn't needed here, since the directory will be wiped out.
        else
          project_url = "file://#{project_name_with_folder}"
          # git_local_exec( "mkdir -p #{project_name_with_folder}" )
          @cli_sequence.add_local_command( "mkdir -p #{project_name_with_folder}", "rm -rf #{project_name_with_folder}" )
          # git_local_exec( "git --bare init #{project_name_with_folder}" )
          @cli_sequence.add_local_command( "git --bare init #{project_name_with_folder}" )
          # git_local_exec( "touch #{project_name_with_folder.join( @gitconf["repo_id"] )}")
          identifier = project_name_with_folder.join( @gitconf["repo_id"] )
          @cli_sequence.add_local_command( "touch #{identifier}", "rm #{identifier}" )
        end
  
        # running locally
        # git_local_exec "git init"
        # git_local_exec "git remote add origin #{project_url}"
        # git_local_exec "git add ."
        # git_local_exec "git commit -a -m \"Initial commit\""
        # git_local_exec "git config branch.master.remote origin"
        # git_local_exec "git config branch.master.merge refs/heads/master"
        # git_local_exec "git push origin master" # need to be explicit the first time  
        @cli_sequence.add_local_command "git init", "rm -rf .git"
        @cli_sequence.add_local_command "git remote add origin #{project_url}"
        @cli_sequence.add_local_command "git add ."
        @cli_sequence.add_local_command "git commit -a -m \"Initial commit\""
        @cli_sequence.add_local_command "git config branch.master.remote origin"
        @cli_sequence.add_local_command "git config branch.master.merge refs/heads/master"
        @cli_sequence.add_local_command "git push origin master" # need to be explicit the first time 
        @cli_sequence.add_local_command "cat /dev/thisactionwillfail"

        if @cli_sequence.execute
          say_all_is_well( "All done.  The url for this project is #{project_url}" )
        else
          say_error( "Command sequence failed." )
        end
      end
      
      protected
      def git_remote_exec( cmd )
        say_subtly( "attempting to run remotely:  #{cmd}" )
        `cd #{@project.target_dir} && ssh #{@gitconf["remote_user"]}@#{@gitconf["remote_host"]} "#{cmd}"`
        say( "Success: #{$?.success?}") 
      end
      
      def git_local_exec( cmd )
        say_subtly( "attempting to run locally:  #{cmd}" )
        `cd #{@project.target_dir} && #{cmd}`
        say( "Success: #{$?.success?}")  
      end
    end
  end
end