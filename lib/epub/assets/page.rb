module EpubForge
  module Epub
    module Assets
      class Page < Asset
        attr_reader :html, :original_file, :title, :project, :media_type, :dest_extension
        attr_accessor :section_id, :section_number

        def initialize file, metadata, project
          raise "NIL" if project.nil?
        
          @metadata = metadata
          @project  = project
          @original_file = file
          @dest_extension = "xhtml"

          @html = Utils::Htmlizer.instance.translate( file )
          @title = File.basename( file ).split(".")[0..-2].map(&:capitalize).join(" : ")
          @content = ""
          puts "Initialized #{file} with title [#{@title}]"
        end
        
        def link
          TEXT_DIR.join( "section#{ sprintf("%04i", @section_number) }.#{@dest_extension}" )
        end
        
        def media_type
          MEDIA_TYPES[@dest_extension]
        end
      end
    end
  end
end