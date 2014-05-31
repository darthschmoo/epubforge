module EpubForge
  module Action
    class HTML < Action2
      define_action( "html" ) do |action|
        action.help( "Create an HTML version of your book" )
        action.execute do
          book_dir = @project.root_dir.join( "book" )
          filename = @project.filename_for_book.ext( "html" )
          html_common( book_dir, filename )
        end

        define_action( "html:notes" ) do |action|
          action.help( "Create an HTML version of your notebook" )
          action.execute do
            book_dir = @project.root_dir.join( "notes" )
            filename = @project.filename_for_notes.ext( "html" )
            html_common( book_dir, filename )
          end
        end
        
        protected
        def html_common( book_dir, filename )
          builder = EpubForge::Builder::Html.new( project, {:book_dir => book_dir} )
          
          builder.build
          builder.package( filename )
          builder.clean
          puts "Done building #{filename}.".paint(:green)
        end
      end
    end
  end
end