module EpubForge
  module Fonts
    class FontDescription
      ATTRIBUTES = :name, :style, :weight, :copyright, :filename, :url
      attr_accessor *ATTRIBUTES

      def to_hash
        ATTRIBUTES.inject({}) do |memo, attribute|
          memo[attribute.to_s] = self.send( attribute )
          memo
        end
      end

      def set_from_hash( hash )
        for attribute in ATTRIBUTES
          if hash.has_key?( attribute.to_s )
            self.send( :"#{attribute}=", hash[attribute.to_s] )
          end
        end
        
        self
      end
      
      def self.set_from_hash( hash )
        self.new.set_from_hash( hash )
      end
      
      def downloaded?
        Fonts.config.cache_dir.join( self.filename ).file?
      end
      
      def download( overwrite = false )
        if (overwrite == true || self.downloaded? == false) && ! self.url.fwf_blank?
          Fonts.config.cache_dir.touch_dir
          puts "Downloading #{self.url}"
          
          Fonts.config.cache_dir.join( self.filename ).write do |io|
            Utils::Downloader.new.download( self.url, io )
          end
        end
      end
      
      def format
        # STUB: Only supporting truetype right now
        "truetype"
      end
    end
  end
end