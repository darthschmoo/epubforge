module EpubForge
  module Builder
    module Assets
      class Stylesheet < Asset
        attr_accessor :filename, :name, :contents
        def initialize( filename )
          @filename = filename.fwf_filepath
          @name     = @filename.basename
          @contents = @filename.read
        end
      
        def link
          STYLE_DIR.join( @name )
        end
        
        def item_id
          @name
        end
        
        # This refers to the Internet media type (image/png, text/css, application/x-font-ttf, etc)
        def media_type
          MEDIA_TYPES["css"]
        end
        
        def 
      end
    end
  end
end