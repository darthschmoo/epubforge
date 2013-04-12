module EpubForge
  module Action
    module SharedActionInterface
      def description( str = nil )
        @description = str if str
        @description
      end
      
      def keywords( *args )
        if args.epf_blank?
          @keywords ||= []
        else 
          @keywords = args.map(&:to_s)
        end
        
        @keywords
      end
      
      def usage( str = nil )
        @usage = str if str
        @usage
      end
      
      def project_required?
        @project_required = true if @project_required.nil?
        @project_required
      end
      
      # Most actions require -- nay, demand! -- a project to act upon.
      # Add the line 'project_not_required' to the class definition
      # to keep it from failing out if it can't find an existing project.
      # Used for things like initializing new projects, or... my imagination
      # fails me.
      def project_not_required
        @project_required = false
      end
    end
    
    class AbstractAction
      extend SharedActionInterface
    end
  end
end