module EpubForge
  module Fonts
    class FontFamilyDescription
      ATTRIBUTES = :name, :designer, :license, :category, :homepage
      attr_accessor *ATTRIBUTES
      attr_accessor :fonts

      def initialize
        @fonts = []
      end

      def to_hash
        starting_hash = { "fonts" => @fonts.map(&:to_hash) }
        
        ATTRIBUTES.inject( starting_hash ) do |memo, attribute|
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
        
        if hash.has_key?( "fonts" )
          @fonts = []
          for font_hash in hash["fonts"]
            @fonts << FontDescription.set_from_hash( font_hash )
          end
        end
        
        infer_home_page_from_name if self.homepage.nil?
        
        self
      end
      
      def filenameize
        self.name.downcase.gsub( " ", "_" )
      end
      
      def self.set_from_hash( hash )
        self.new.set_from_hash( hash )
      end
      
      def self.from_yaml_file( file )
        lookup = Lookup.new
        
        hash = YAML.load( file.read )
        
        hash.map{ |family_name, font_hash|
          font_family = EpubForge::Fonts::FontFamilyDescription.set_from_hash( font_hash )
          lookup.register( font_family )
        }
        
        lookup
      end
      
      def download( overwrite = false )
        for font in self.fonts
          font.download
        end
      end
      
      protected
      def infer_home_page_from_name
        self.homepage = "http://www.google.com/fonts/specimen/#{self.name.gsub(" ", "+" )}"
      end
    end
  end
end