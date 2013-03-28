module EpubForge
  module Action
    class GitBackup < AbstractAction
      description "commit your project to the git repo and back it up"
      keywords :backup, :save, :commit
      usage       "#{$PROGRAM_NAME} commit <project directory (optional if current dir)> \"optional message\""
      
      def is_git?
        File.exist?( File.join( @project.target_dir, ".git" ) )
      end
      
      def do( project, args = [] )
        puts "Received arguments #{args.inspect} (#{args.class})"
        @project = project
        @message = args.length > 1 ? args.last : "incremental backup"
        
        unless is_git?
          puts "Not a git-backed project.  Aborting."
          return false
        end
        
        `cd #{@project.target_dir} && git commit -a -m "#{@message}" && git push`
      end
    end
  end
end