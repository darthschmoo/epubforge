module EpubForge
  module Action
    class NotesToEpub < AbstractAction
      description "Create an epub book from the .markdown files in the project's notes/ subdirectory."
      keywords    :notes, :forge_notes
      usage       "#{$PROGRAM_NAME} notes <project_directory>"
      
      def do( project, *args )
        @project = project
        builder = EpubForge::Epub::Builder.new( @project, book_dir: @project.target_dir.join("notes"), 
                                                          page_order: @project.config["pages"]["notes"] )
                                                          
        builder.build
        builder.package( @project.filename_for_epub_notes )
        builder.clean
        puts "Done"
      end
    end
  end
end