
module EpubForge
  module Utils
    module HtmlTranslatorQueue
      GROUP_NAMES = [:preferred, :user, :default, :fallback]
      
      def self.included( base )
        base.send( :include, FunWith::Patterns::Loader )
        base.extend( HtmlTranslatorQueue::ClassMethods )
        base.loader_pattern_only_register_classes( self )
      end
      
      module ClassMethods
        def loader_pattern_register_item( translator )
          @translators ||= {}
          @translators[:all] ||= []
          @translators[:named] ||= {}
        
          for name in HtmlTranslatorQueue::GROUP_NAMES
            @translators[name] ||= []
          end

          self.categorize( translator )

          nil    # returning true will break loader
        end
      
      
      
        def translators
          @translators
        end
      
        def categorize( translator )
          unless GROUP_NAMES.include?( translator.group )
            puts "No group specified for html translator #{translator}.  Group must be one of the following symbols: #{GROUP_NAMES.map(&:inspect).inspect}"
            return false 
          end
        
          @translators[:all] << translator
          @translators[:named][translator.name] = translator if translator.name
          @translators[translator.group] << translator
        end
      
        def named( sym )
          @translators[:named][sym]
        end
      
        def each_translator( &block )
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
      
        def location( name, path = nil )
          @exec_location ||= {}
          @exec_location[name] = path if path
          @exec_location[name]
        end
      end
    end
  end
end

#     # A priority stack (like a priority queue, but FILO) with a simple job: 
#     # keep track of the translators (by name and by group), and return them
#     # to the object user in the order they should be tried.
#     class HtmlTranslatorQueue
#       def self.group_names
#         HtmlTranslator::GROUP_NAMES
#       end
#       
#       def initialize
#         @translators = {}
#         @all_translators = []
#         @translators_named = {}
#         for name in GROUP_NAMES
#           @translators[name] = []
#         end
#       end
#       
#       # def translators_handling_format( requested_format )
#       #   htmlizers = GROUP_NAMES.map{ |group|
#       #     (@translator_queue.keys - [:all, :named]).map do |format|
#       #       htmlizers = @translator_queue[format][group]
#       #       htmlizers ? htmlizers.select{|html| html.handles_format?(requested_format) } : []
#       #     end
#       #   }
#       #   
#       #   htmlizers.flatten
#       # end
#       
#       # last installed, first yielded (within a given group)
#       # 
#       # Returns them in priority order, user-defined ones first.
#       # At the moment, it is up to individual translators to accept or
#       # reject the translation job based on the file format (by extension, which is lame).
#       
#       def length
#         @all_translators.length
#       end
#     end
#   end
# end