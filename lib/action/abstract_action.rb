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
        if args.length == 0
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
      
      def self.project_required?
        @project_required = true if @project_required.nil?
        @project_required
      end
      
      # Most actions require -- nay, demand! -- a project to act upon.
      # Add the line 'project_not_required' to the class definition
      # to keep it from failing out if it can't find an existing project.
      # Used for things like initializing new projects, or... my imagination
      # fails me.
      def self.project_not_required
        @project_required = false
      end
    end
  end
end