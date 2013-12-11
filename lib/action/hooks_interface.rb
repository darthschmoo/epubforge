# NOT EVEN REMOTELY DONE
module EpubForge
  module Actions
    class HooksInterface
      def add_hook( hookset, block )  # Symbol: either :before or :after
        
      end
      
      def run_hooks( hookset )
        super( hookset ) unless self == ThorAction
        
      end
        
      def self.included( base )
        if base == ThorAction
          base.add_hook(:before) do
            @project = @options[:project]
          end
        end
      end
    end
  end
end