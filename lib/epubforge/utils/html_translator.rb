module EpubForge
  module Utils
    # An individual translator, which receives a filename, determines if it's up to the job
    # then returns the resulting HTML translation.
    class HtmlTranslator
      include HtmlTranslatorQueue

      get_and_set( :name, :opts, :format, :cmd )
      
      def self.translate( filename, opts = {} )
        translator  = opts[:translator]
        translator  = self.named( translator ) if translator.is_a?( Symbol )
        opts      = opts[:opts] || ""
        
        if translator
          if result = translator.translate( filename, {opts: opts } )
            return result
          else
            puts "Named HtmlTranslator #{translator} did not return html. Falling back on other html translators"
          end
        end

        for translator in HtmlTranslator.each_translator
          if result = translator.translate( filename, opts )
            return result
          end
        end
        
        "<!-- COULD NOT FIND HTML TRANSLATOR FOR FORMAT (#{filename}) -->"
      end

      # Unneeded?
      # def self.format_from_filename( filename )
      #   ext = filename.fwf_filepath.ext
      #   ext.fwf_blank? ? :unknown : ext.to_sym
      # end
      # 
      
      
      
      def initialize( &block )
        # set some defaults
        group( :user )
        opts( "" )
        
        self.instance_exec( &block ) if block_given?
        self      # explicitly return.  Thought that wasn't necessary, but...
      end
    
      def group( g = nil )
        if g
          raise "group must be one of the following symbols: #{HtmlTranslatorQueue::GROUP_NAMES.inspect}" unless HtmlTranslatorQueue::GROUP_NAMES.include?(g)
          @group = g 
        end
      
        @group
      end
    
      def executable( executable_name = nil )
        if executable_name
          @executable_name = HtmlTranslator.location( executable_name ) || `which #{executable_name}`.strip
        end
        @executable_name || ""
      end
    
    
      def custom_proc( *args, &block )
        if block_given?
          @custom_proc = block
        elsif args.first.is_a?(Proc)
          @custom_proc = args.first
        end
      
        @custom_proc
      end

      def installed?
        executable.length > 0
      end
    
      def handles_format?( f )
        @format == get_file_format( f ) || @format == :unknown
      end
    
      def can_do_job?( f )
        handles_format?( f ) && ( has_executable_installed? || has_custom_proc? )
      end

      def has_executable_installed?
        executable.is_a?(String) && ! executable.fwf_blank?     # 'which will return an empty string if the given executable isn't in the path'
      end
      
      def has_custom_proc?
        @custom_proc.is_a?( Proc )
      end
      
      # opts allows you to override the normal command line arguments
      # Maybe a description of the job's requirements should be more
      # elaborate than just a filename.  OTOH, simple can have its advantages.
      def translate( filename, opts = "" )
        return false unless can_do_job?( filename )
      
        result =  ""
        if @custom_proc
          result += @custom_proc.call( filename, *opts )
        elsif @cmd
          exec_string = cmd.gsub( /\{\{f\}\}/, "\"#{filename.to_s}\"" )
          opts = @opts if opts.fwf_blank?
          exec_string.gsub!( /\{\{o\}\}/, opts )
          exec_string.gsub!( /\{\{x\}\}/, executable )
        
          result += `#{exec_string}`
        else
          return false
        end
      
        # Debugging only.
        # result += "\n\n<!-- generated from #{@format} by html translator #{@name} -->\n" 
        result
      end
    
      def get_file_format( file )
        file.fwf_filepath.ext.to_sym
      end
    end
  end
end