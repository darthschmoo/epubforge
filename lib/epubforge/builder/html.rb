module EpubForge
  module Builder
    class Html < Builder
      def build
        @html_content = ""
        
        @sections.each do |section|
          @html_content << section.html
          @html_content << "\n\n"         # couldn't hurt?
        end
      end
      
      def package( html_filename )
        html_filename.write( wrap_page( @html_content ) )
      end
      
      def clean
        # do nothing
      end
    end
  end
end