module EpubForge
  module Epub
    module Assets
      class Font < Asset
        attr_reader :ext, :filename, :name
        def initialize( filename, options = {} )
          @filename = filename.fwf_filepath
          @name, @ext  = @filename.basename_and_ext
        end
        
        def link
          FONT_DIR.join( @filename.basename.to_s )
        end
        
        def item_id
          @filename.basename.to_s
        end
      end
    end
  end
end
