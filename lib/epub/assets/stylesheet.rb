module EpubForge
  module Epub
    module Assets
      class Stylesheet < Asset
        attr_accessor :filename, :name, :contents
        def initialize( filename )
          @filename = filename.epf_filepath
          @name     = @filename.basename
          @contents = @filename.read
        end
      
        def link
          STYLE_DIR.join( @name )
        end
        
        def media_type
          MEDIA_TYPES["css"]
        end
      end
    end
  end
end