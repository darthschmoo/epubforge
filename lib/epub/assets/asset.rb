module EpubForge
  module Epub
    module Assets
      class Asset
        def media_type
          MEDIA_TYPES[@ext]
        end
      end
    end
  end
end