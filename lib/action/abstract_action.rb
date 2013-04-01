module EpubForge
  module Action
    class AbstractAction
      attr_reader :description
      attr_reader :keywords
      attr_reader :usage
      
      def self.description( str = nil )
        if str
          @description = str
        end
        
        @description
      end
      
      def self.keywords( *args )
        if args.epf.blank?
          @keywords ||= []
        else 
          @keywords = args.map(&:to_s)
        end
        
        @keywords
      end
      
      def self.usage( str = nil )
        if str
          @usage = str
        end
        
        @usage
      end
      
      def fetch_project( dir )
        Epub::Project.new( dir )
      end
    end
  end
end