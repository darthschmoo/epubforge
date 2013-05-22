module EpubForge
  module Action
    class RunDescription
      attr_accessor :args,
                    :project,
                    :keyword,
                    :klass,
                    :errors,
                    :state,
                    :execution_returned
      
      def initialize
        @args = nil
        @project = nil
        @keyword = nil
        @klass = nil
        @errors = []
        @state = :initialized
      end

      def run
        if self.runnable?
          handle_errors do
            @execution_returned = self.klass.new.do( self.project, *(self.args) )
          end
        else
          puts "Error(s) trying to complete the requested action:"
          puts self.errors.join("\n")
        end
        
        self.finish
        self
      end
      
      def handle_errors &block
        yield
      rescue Exception => e
        @errors << "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
        self
      end
      
      
      def runnable?
        ! errors?
      end
      
      def errors?
        !@errors.epf_blank?
      end
      
      def success?
        finished? && ! errors?
      end
      
      def finished?
        @state == :finished
      end
      
      def finish
        @state = :finished
      end
      
      def to_s
        str = "RunDescription:\n"
        [ :args, :project, :keyword, :klass, :errors, :state ].each do |data|
          str << "#{data} : #{self.send(data)}\n"
        end

        str
      end
    end
  end
end
    
