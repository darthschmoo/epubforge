module EpubForge
  module Epub
    class Image
      MEDIA_TYPES = { "gif" => "image/gif", "jpg" => "image/jpeg", "png" => "image/png"}
  
      attr_reader :ext, :file, :name
      def initialize( filename, options = {} )
        @file = filename
        @name = File.basename( @file ).split(".")[0..-2].join(".")
        @ext = File.extname( @file )[1..-1]
      end
  
      def media_type
        MEDIA_TYPES[@ext]
      end
    end
  end
end