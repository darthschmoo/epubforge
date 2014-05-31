module EpubForge
  module Builder
    module Assets
      class Image < Asset
        attr_reader :ext, :filename, :name
        def initialize( filename, options = {} )
          @filename = filename.fwf_filepath
          @name, @ext  = @filename.basename_and_ext
        end
  
        def link
          IMAGE_DIR.join( "#{@name}.#{@ext}"  )
        end
        
        def item_id
          cover? ? "cover-image" : self.link.basename
        end
        
        def cover?
          self.name == "cover"
        end
      end
    end
  end
end