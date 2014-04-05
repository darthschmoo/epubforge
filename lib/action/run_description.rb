module EpubForge
  module Action
    class RunDescription
      attr_accessor :args,
                    :project,
                    :namespace,
                    :subcommand,
                    :klass,
                    :errors,
                    :state,
                    :execution_returned
      
      def initialize
        @args = nil
        @project = nil
        @namepace = nil
        @subcommand = nil
        @klass = nil
        @errors = []
        @state = :initialized
      end

      def run
        if self.runnable?
          handle_errors do
            @args[0] = (@args[0]).split(":").last
            puts "Run Description: #{@args.inspect}"
            # debugger if @args.first == "init"
            @execution_returned = self.klass.start( @args )
          end
        end

        report_errors if errors?
        
        self.finish
        self
      end
      
      def handle_errors &block
        yield
      rescue Exception => e
        @errors << "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
        self
      end

      def report_errors
        puts @errors.join("\n\n------------------------------------------------------------------\n\n")
        puts "Error(s) trying to complete the requested action:"
      end
      
      def quit_on_errors
        if self.errors?
          self.finish
          self.report_errors
          exit( -1 )
        end
      end
      
      def runnable?
        ! errors?
      end
      
      def errors?
        !@errors.fwf_blank?
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
        [ :args, :project, :namespace, :subcommand, :klass, :errors, :state ].each do |data|
          str << "#{data} : #{self.send(data).inspect}\n"
        end

        str
      end
    end
  end
end
    
