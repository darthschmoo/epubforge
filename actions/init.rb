
module EpubForge
  module Action
    class Init < AbstractAction
      description "Create a new epubforge project."
      keywords    :init, :initialize, :new
      usage       "#{$PROGRAM_NAME} init <project_directory> (directory shouldn't exist)"
      needs_no_project
      
      def do( project, args )
        target_dir = args.pop

        if target_dir.nil?
          puts "You must specify a target directory."
          puts usage
          puts "\n"
          exit 0
        end

        @project = Project.new( target_dir )
        
        @src_dir = EpubForge::TEMPLATE_DIR
        @dst_dir = @project.target_dir
        
        if @dst_dir.exist?
          puts "Directory already exists.  No action taken.  Please choose an empty directory."
        elsif !@src_dir.exist?
          puts "No template resides in directory : #{@src_dir}.  No action taken."
        else
          create_project
        end
      end
      
      def create_project
        `cp -R #{@src_dir} #{@dst_dir}`
      end
    end
  end
end