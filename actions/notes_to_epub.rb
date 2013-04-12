module EpubForge
  module Action
    class NotesToEpub < ThorAction
      description "Create an epub book from the .markdown files in the project's notes/ subdirectory."
      keywords    :notes, :forge_notes
      usage       "#{$PROGRAM_NAME} notes <project_directory> (optional if current directory)"
      
      desc( "do:notes", "Wraps your story notes up in a .epub (ebook) file." )
      def do( project, *args )
        @project = project
        builder = EpubForge::Epub::Builder.new( @project, book_dir: @project.target_dir.join("notes"), 
                                                          page_order: @project.config["pages"]["notes"] )
        builder.build
        builder.package( @project.filename_for_epub_notes )
        builder.clean
        puts "Done building epub <#{@project.filename_for_epub_notes}>"
      end
    end
  end
end