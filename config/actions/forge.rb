module EpubForge
  module Action
    class Forge < ThorAction
      include_standard_options
      description "Create ebooks in various formats from the .markdown files in the project's book/ and notes/ subdirectories."
      
      desc( "forge", "Wraps the project up in a .epub (ebook) file.")
      def forge( *args )
        before_start

        builder = EpubForge::Epub::Builder.new( @project, :page_order => @project.config["pages"]["book"] )

        builder.build
        builder.package( @project.filename_for_epub_book )
        builder.clean
        puts "Done building epub <#{@project.filename_for_epub_book}>"
      end
      
      desc( "forge:epub", "Wraps the project up in a .epub (ebook) file." )
      alias :epub :forge   # I _think_ this will allow me to also use forge:epub as an alias for forge
    end
  end
end