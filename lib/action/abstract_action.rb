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
      
      # Not all actions require a target project to run, but the default assumpion
      # is that the action will be executed on a project.  To contradict the assumption,
      # declare 'needs_no_project' or 'needs_project( false )' in your definition.
      def self.needs_project?
        defined?(@needs_project) ? @needs_project : true
      end
      
      def self.needs_no_project
        @needs_project = false  
      end
      
      def self.needs_project( bool = true )
        @needs_project = bool
      end

      def needs_project?
        self.class.needs_project != false
      end
    end
  end
end