module EpubForge
  module Action
    class Forge < Action2
      define_action( "forge" ) do |action|
        action.help( "Create all book formats" )
          
        action.execute do
          raise "todo"
          builder = EpubForge::Builder::Epub.new( project )
          build( builder, project.filename_for_book.ext("epub") )
        end
      end
      
      define_action( "forge:notes" ) do |action|
        action.help( "Create all formats of of book's notes.")
        
        action.execute do
          raise "todo"
          builder = EpubForge::Builder::Epub.new( project, book_dir: project.notes_dir, 
                                                           page_order: project.config[:pages][:notes] )
        
          build( builder, project.filename_for_notes.ext("epub") )
        end
      end
      
      define_action( "forge:formats" ) do |action|
        action.help( "List information about which ebook formats are available." )
        
        action.execute do
          puts "TODO!".paint( :bg_red, :white, :bold )
          raise "todo"
        end
      end
      
      def build( builder, builds_file )
        builder.build
        builder.package( builds_file )
        builder.clean
        puts "Done building epub <#{builds_file}>"
      end
    end
  end
end