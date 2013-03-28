module EpubForge
  module Action
    class RunDescription
      attr_accessor :args
      attr_accessor :project
      attr_accessor :keyword
      attr_accessor :klass
      
      def initialize
        @keyword = "help"
        @project = ""
        @args    = []
        @klass   = AbstractAction
      end
    end
  end
end
    
