module EpubForge
  module Utils
    # An individual translator, which receives a filename, determines if it's up to the job
    # then returns the resulting HTML translation.
    class HtmlTranslator
      GROUP_NAMES = [:preferred, :user, :default, :fallback]
    
      def initialize
        group( :user )
        opts( "" )
      end
    
      def name( n = nil )
        @name = n if n
        @name
      end
    
      def group( g = nil )
        if g
          raise "group must be one of the following symbols: #{GROUP_NAMES.inspect}" unless GROUP_NAMES.include?(g)
          @group = g 
        end
      
        @group
      end
    
      def executable executable_name = nil
        if executable_name
          @executable_name = Htmlizer.instance.location( executable_name ) || `which #{executable_name}`.strip
        end
        @executable_name || ""
      end
    
      def format f = nil
        @format = f if f
        @format
      end
    
      def cmd c = nil
        @cmd = c if c
        @cmd
      end
    
      def custom_proc( p = nil, &block )
        if block_given?
          @custom_proc = block
        else
          @custom_proc = c if c
        end
      
        @custom_proc
      end
    
      def opts o = nil
        @opts = o if o
        @opts
      end
    
      def installed?
        executable.length > 0
      end
    
      def handles_format?( f )
        @format == determine_file_format( f ) || @format == :unknown
      end
    
      def can_do_job?( f )
        installed? && handles_format?( f )
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
          exec_string = cmd.gsub( /\{\{f\}\}/, filename.to_s )
          opts = @opts if opts.fwf_blank?
          exec_string.gsub!( /\{\{o\}\}/, opts )
          exec_string.gsub!( /\{\{x\}\}/, executable )
        
          result += `#{exec_string}`
        else
          return false
        end
      
        result += "\n\n<!-- generated from #{@format} by htmlizer #{@name} -->\n" 
        result
      end
    
      def determine_file_format( file )
        file.fwf_filepath.ext.to_sym
      end
    end
  end
end