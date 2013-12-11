module EpubForge
  module Action
    class Forge < ThorAction
      include_standard_options
      
      desc( "forge:notes", "Wraps your story notes up in a .epub (ebook) file." )
      def notes( *args )
        before_start
        builder = EpubForge::Epub::Builder.new( @project, book_dir: @project.target_dir.join("notes"), 
                                                          page_order: @project.config[:pages][:notes] )
        builder.build
        builder.package( @project.filename_for_epub_notes )
        builder.clean
        puts "Done building epub <#{@project.filename_for_epub_notes}>"
      end
    end
  end
end