module EpubForge
  module Action
    class NotesToKindle < Kindle
      description "Create a .mobi book from the notes and try to push it to your Kindle"
      keywords    :n2k
      usage       "#{$PROGRAM_NAME} n2k <project_directory>"
  
      def do( project, args )
        @project = project
        project_dir = @project.target_dir
    
        NotesToEpub.new.do( @project )
        @project = EpubForge::Project.new( project_dir )
    
        if mobify @project.filename_for_epub_notes, @project.filename_for_mobi_notes
          puts "Formatted for Kindle (.mobi file)"
          push_to_device @project.filename_for_mobi_notes
        end
      end
    end
  end
end