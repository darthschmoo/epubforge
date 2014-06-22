module EpubForge
  module Fonts
    class Lookup
      def register( font_family )
        self.register_by_category( font_family )
        self.register_by_name( font_family )
      end
      
      def lookup( str = nil )
        names = str.nil? ? @name.keys : @name.keys.select{ |n| n =~ /#{str}/i }
        names.map{ |name| @name[name] }
      end
      
      def []( family_name )
        @name[ family_name ]
      end
      
      protected
      def register_by_category( font_family )
        @category ||= {}
        category = font_family.category
        category = "Misc" if category.fwf_blank?
        
        (@category[category] ||= []) << @font
      end
      
      def register_by_name( font_family )
        name = font_family.name
        
        @name ||= {}
        @name[ name ] = font_family
      end
    end
  end
end