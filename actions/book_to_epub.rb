module EpubForge
  module Action
    class BookToEpub < AbstractAction
      description "Create an epub book from the .markdown files in the project's book/ subdirectory."
      keywords    :forge, :book
      usage       "#{$PROGRAM_NAME} forge <project_directory (optional if current directory)>"
      
      def do( project, *args )
        @project = project
        
        builder = EpubForge::Epub::Builder.new( @project.book_dir, @project.config )
        
        builder.build
        builder.package( @project.filename_for_epub_book )
        builder.clean
        puts "Done building epub <#{@project.filename_for_epub_book}>"
      end
    end
  end
end