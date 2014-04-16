module EpubForge
  module Utils
    
    # Htmlizer coordinates the discovery, selection, and running of HtmlTranslators.
    # It can be handed basically any supported filetype (markdown, textile, txt), and 
    # hand back an HTML translation of the file.
    class Htmlizer
      include Singleton

      def setup_once
        return false if @already_set_up 
        @already_set_up = true
        @exec_location = {}
        
        @translator_queue = HtmlTranslatorQueue.new
        
        add_htmlizers( EpubForge.root( 'config', 'htmlizers.rb' ) )
        add_htmlizers( EpubForge::USER_SETTINGS.join( 'htmlizers.rb' ) )
        
        @already_set_up
      end
            
      public
      def location( name, path = nil )
        @exec_location[name] = path if path
        @exec_location[name]
      end

      # Commenting out for the moment.  Philosophically, maybe it shouldn't provide access to individual translators.
      # def translators_named( name )
      #   @translator_queue[:named][name]
      # end

      
      def self.define( &block )
        htmlizer = HtmlTranslator.new
        yield htmlizer
        self.instance.categorize( htmlizer )
      end
      
      def categorize( htmlizer )
        @translator_queue.categorize( htmlizer )
      end
      
      def add_htmlizers( htmlizers_file )
        if htmlizers_file.exist?
          begin
            require htmlizers_file.to_s
          rescue Exception => e
            puts e.message
            puts e.backtrace.map{|line| "\t#{line}" }
            puts "Failed to load htmlizers from project file #{htmlizers_file} Soldiering onward."
          end
        end
      end

      
      # available options
      # :htmlizer => the sym for the requested htmlizer.  
      # :opts     => a string representing options to execute cmd with
      def translate( filename, opts = {} )
        translator  = opts[:translator]
        translator  = @translator_queue.named( translator ) if translator.is_a?( Symbol )
        opts      = opts[:opts] || ""
        
        if translator
          if result = translator.translate( filename, {opts: opts } )
            return result
          else
            puts "Named Htmlizer #{htmlizer} did not return html. Falling back on other htmlizers"
          end
        end

        for translator in @translator_queue
          if result = translator.translate( filename, opts )
            return result
          end
        end
        
        "<!-- COULD NOT FIND HTMLIZER FOR #{filename} -->"
      end
      
      def self.format_from_filename( filename )
        ext = filename.fwf_filepath.ext
        ext.fwf_blank? ? :unknown : ext.to_sym
      end
    end
    
    Htmlizer.instance.setup_once
  end
end

