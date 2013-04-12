module EpubForge
  module Action
    class GitBackup < ThorAction
      description "commit your project to the git repo and back it up"
      keywords :backup, :save, :commit
      usage       "#{$PROGRAM_NAME} commit <project directory (optional if current dir)> \"optional message\""
            
      desc( "do:save", "save to your git repository")
      def do( project, *args )
        @project = project
        @message = args.length > 0 ? args.last : "incremental backup"
        
        unless project_already_gitted?
          say_error "Not a git-backed project.  Aborting."
          say_instruction "Run 'epubforge gitify <project>' to create a backup repository."
          return false
        end
        
        `cd #{@project.target_dir} && git commit -a -m "#{@message}" && git push`
      end
    end
  end
end