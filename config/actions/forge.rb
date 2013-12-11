module EpubForge
  module Action
    class BookToEpub < ThorAction
      description "Create an epub book from the .markdown files in the project's book/ subdirectory."
      keywords    :forge, :book
      usage       "#{$PROGRAM_NAME} forge <project_directory (optional if current directory)>"
      
      desc( "do:forge", "Wraps the project up in a .epub (ebook) file.")
      def do( project, *args )
        @project = project
        builder = EpubForge::Epub::Builder.new( @project, :page_order => @project.config["pages"]["book"] )

        builder.build
        builder.package( @project.filename_for_epub_book )
        builder.clean
        puts "Done building epub <#{@project.filename_for_epub_book}>"
      end
    end
  end
end