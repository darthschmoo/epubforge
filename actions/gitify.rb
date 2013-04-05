module EpubForge
  module Action
    class Gitify < AbstractAction
      description "create a remote git repository of the project folder"
      keywords    :gitify, :git_init
      usage       "#{$PROGRAM_NAME} gitify <project_directory>"
      
      
      def git_remote_exec( cmd )
        puts "attempting to run remotely:  #{cmd}"
        `cd #{@project.target_dir} && ssh tux "#{cmd}"`  
      end
      
      def git_local_exec( cmd )
        puts "attempting to run locally:  #{cmd}"
        `cd #{@project.target_dir} && #{cmd}`  
      end

      def is_git?
        File.exist?( File.join( @project.target_dir, ".git" ) )
      end
      
      def do( project, *args )
        @project = project
        @gitconf = @project.config["git"]
        
        if is_git?
          puts "Already seems to be a git project. delete the .git folder if this is incorrect."
          return false
        end
        
        pname = "#{@project.config["filename"]}.writ.git"
        pname_with_folder = File.join( @gitconf["repo_folder"], pname )
        project_url = "ssh://#{@gitconf["remote_user"]}@#{@gitconf["remote_host"]}#{pname_with_folder}"
        
        git_remote_exec( "mkdir -p #{pname_with_folder}" )
        git_remote_exec( "cd #{pname_with_folder} && git --bare init" )
      
        puts "The url for this project is #{project_url}"
      
        # running locally
        git_local_exec "git init"
        git_local_exec "git remote add origin #{project_url}"
        git_local_exec "git add ."
        git_local_exec "git commit -a -m \"Initial commit\""
        git_local_exec "git config branch.master.remote origin"
        git_local_exec "git config branch.master.merge refs/heads/master"
        git_local_exec "git push origin master" # need to be explicit the first time  

        puts "Done"
      end
    end
  end
end