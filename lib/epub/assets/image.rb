module EpubForge
  module Epub
    module Assets
      class Image < Asset
        attr_reader :ext, :filename, :name
        def initialize( filename, options = {} )
          @filename = filename.fwf_filepath
          @name     = @filename.basename.to_s.split(".")[0..-2].join(".")
          @ext      = @filename.extname.gsub( /^\./, "" )
        end
  
        def link
          IMAGES_DIR.join( @name )
        end
      end
    end
  end
end