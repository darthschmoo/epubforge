module EpubForge
  module Utils
    # A priority stack (like a priority queue, but FILO) with a simple job: 
    # keep track of the translators (by name and by group), and return them
    # to the object user in the order they should be tried.
    class HtmlTranslatorQueue
      GROUP_NAMES = HtmlTranslator::GROUP_NAMES
      
      
      def initialize
        @translators = {}
        @all_translators = []
        @translators_named = {}
        for name in GROUP_NAMES
          @translators[name] = []
        end
      end
      
      # def translators_handling_format( requested_format )
      #   htmlizers = GROUP_NAMES.map{ |group|
      #     (@translator_queue.keys - [:all, :named]).map do |format|
      #       htmlizers = @translator_queue[format][group]
      #       htmlizers ? htmlizers.select{|html| html.handles_format?(requested_format) } : []
      #     end
      #   }
      #   
      #   htmlizers.flatten
      # end
      
      # last installed, first yielded (within a given group)
      # 
      # Returns them in priority order, user-defined ones first.
      # At the moment, it is up to individual translators to accept or
      # reject the translation job based on the file format (by extension, which is lame).
      def each( &block )
        ordered_translators = []
        for group in GROUP_NAMES.map{|g| @translators[g].reverse }
          ordered_translators += group
        end
        
        if block_given?
          for translator in ordered_translators
            yield translator
          end
        else
          ordered_translators.to_enum
        end
      end
      
      def length
        @all_translators.length
      end
      
      def categorize( htmlizer )
        unless GROUP_NAMES.include?( htmlizer.group )
          puts "No group specified for htmlizer #{htmlizer}.  Group must be one of the following symbols: #{GROUP_NAMES.map(&:inspect).inspect}"
          return false 
        end
        
        @all_translators << htmlizer
        @translators_named[htmlizer.name] = htmlizer if htmlizer.name
        @translators[htmlizer.group] << htmlizer
      end
      
      def named( sym )
        @translators_named[sym]
      end
    end
  end
end