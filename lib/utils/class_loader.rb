module EpubForge
  module Utils
    # filepath string with metadata, representing a class 
    # file that can be loaded.
    class ClassLoader < FunWith::Files::FilePath
      def self.loaded_classes
        @loaded_classes ||= []
      end
      
      def self.loaded_directories
        @loaded_directories ||= []
      end
      
      def self.namespace( nsp = nil )
        @namespace = nsp unless nsp.nil?
        @namespace
      end
  
      def class_name
        unless @class_name
          base = self.basename.to_s.split(".")[0].epf_camelize
          @class_name = "#{self.class.namespace}::#{base}"
        end
        @class_name
      end
  
      # Returns true if an error was raised when trying to require the file,
      # or if the expected class is not loaded after the file was required.
      # Proper naming is very important here.
      def require_me
        begin
          require self.to_s
        rescue NameError => e
          puts "Error encounterd while trying to load #{self.class_name} from #{self}"
          puts e.message
          puts e.backtrace.map{|line| "\t#{line}" }
          return false
        end
        
        return self.class_loaded?
      end
  
      def class_loaded?
        begin
          self.to_class
          return true
        rescue NameError     # There's gotta be another way I should be doing this.
          return false
        end
      end
  
      def to_class
        return @klass unless @klass.nil?
        @klass = Utils::Misc.constantize( self.class_name )
      end
      
      def self.require_me( *loadables )
        @loaded_classes ||= []
        @loaded_directories ||= []
        
        for loadable in loadables
          loadable = self.new( loadable )
          
          if loadable.file?
            if loadable.require_me
              @loaded_classes << loadable.to_class
            else
              puts "Warning: Failed to load #{loadable.class_name} from file #{loadable}"
            end
          elsif loadable.directory?
            @loaded_directories << loadable
            loadable.glob( "**", "*.rb" ).each do |entry|
              self.require_me( entry )
            end
          else
            puts "Warning: Could not find file #{loadable} to load classes from."
          end
        end
      end
      
      # just loading all the files is simpler, and probably little harm from reloading.  Plus, I want
      # to be able to split up existing ThorClasses across multiple files.
      def self.load_me( *loadables )
        silence_warnings do
          for loadable in loadables
            loadable = loadable.fwf_filepath
          
            if loadable.file?
              load( loadable )
            elsif loadable.directory?
              for entry in loadable.glob( :ext => "rb", :recursive => true )
                load( entry )
              end
            else
              puts "Warning: No idea what I'm trying to load (#{loadable}:#{loadable.class})"
            end
          end
        end
      end
    end
  end
end