module EpubForge
  module Action
    class Mobi < Action2
      define_action( "mobi" ) do |action|
        action.help( "Converts .epub to .mobi." )
        
        action.execute do
          converters = Utils::Converter.converts( :epub, :mobi )
          
          # TODO: Uses the first converter it finds.  Suboptimal.
          for converter in converters
            if converter.is_executable_installed?
              @converter = converter
              break
            end
          end
          mobi_convert_common
        end
      end
      
      define_action( "mobi:convert:calibre" ) do |action|
        action.help( "Converts .epub to .mobi, using Calibre's ebook-convert utility" )
        action.execute do
          @converter = Utils::Converter[:epub_to_mobi_calibre]
          mobi_convert_common
        end
      end
      
      define_action( "mobi:convert:kindlegen" ) do |action|
        action.execute do
          @converter = Utils::Converter[:epub_to_mobi_kindlegen]
          mobi_convert_common
        end
      end
      
      protected
      def mobi_convert_common
        src  = @project.filename_for_book.ext( "epub" )
        dest = @project.filename_for_book.ext( "mobi" )
        
        unless src.file?
          puts "Failure: source .epub doesn't exist: #{src}".paint(:red)
        end
        
        # Sigh, Kindlegen is stupid
        if @converter.label == :epub_to_mobi_kindlegen          
          dest = dest.basename
        end
        
        conversion = @converter.convert( src, { :dest => dest, :command_line_options => "" } )

        if conversion
          puts "Success!".paint(:green)
        else
          puts "Failure!".paint(:red)
        end
      end
    end
  end
end
