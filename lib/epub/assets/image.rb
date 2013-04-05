module EpubForge
  module Epub
    module Assets
      class Image < Asset
        attr_reader :ext, :file, :name
        def initialize( filename, options = {} )
          @filename = filename.epf_filepath
          @name     = @filename.basename.split(".")[0..-2].join(".")
          @ext      = @filename.extname.gsub( /^\./, "" )
        end
  
        def link
          IMAGES_DIR.join( @file )
        end
      end
    end
  end
end