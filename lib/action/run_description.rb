module EpubForge
  module Action
    class RunDescription
      attr_accessor :args
      attr_accessor :project
      attr_accessor :keyword
      attr_accessor :klass
      attr_accessor :errors
      
      def initialize
        @args = nil
        @project = nil
        @keyword = nil
        @klass = nil
        @errors = []
      end
      
      def runnable?
        @errors.epf_blank?
      end
    end
  end
end
    
