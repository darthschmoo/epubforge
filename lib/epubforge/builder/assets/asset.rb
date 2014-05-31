module EpubForge
  module Builder
    module Assets
      class Asset
        def media_type
          MEDIA_TYPES[@ext]
        end
        
        def cover?
          false
        end
      end
    end
  end
end