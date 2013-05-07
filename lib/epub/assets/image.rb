module EpubForge
  module Epub
    module Assets
      class Image < Asset
        attr_reader :ext, :filename, :name
        def initialize( filename, options = {} )
          @filename = filename.fwf_filepath
          @name, @ext  = @filename.basename_and_ext
        end
  
        def link
          IMAGES_DIR.join( "#{@name}.#{@ext}"  )
        end
      end
    end
  end
end