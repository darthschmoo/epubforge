module EpubForge
  module Utils
    
    # TODO: Starting to get the feeling that an HtmlTranslator is just a subtype of Converter.
    class Converter
      get_and_set :command, :executable, :help, :input_format, :label, :output_format

      include FunWith::Patterns::Loader
      loader_pattern_configure( :bracketwise_lookup, 
                                :warn_on_key_change, 
                                { :key => :label, :verbose => true } )
                                
      def self.all
        self.loader_pattern_registry
      end
      
      def self.converts( input_format, output_format = :any )
        self.all.select{ |k,v|
          if v.input_format == input_format
            output_format == :any || v.output_format == output_format
          else
            false
          end
        }.values
      end
      
      def initialize( &block )
        instance_exec( &block ) 
        @command ||= "{{x}} {{o}} '{{src}}' '{{dst}}'"   # default
        self
      end
      
      # def label( lbl = nil )
      #   @label = lbl unless lbl.nil?
      #   @label
      # end
      # 
      # def from( fmt = nil)
      #   @src_format = fmt unless fmt.nil?
      #   @src_format
      # end
      # 
      # def to( fmt = nil)
      #   @dst_format = fmt unless fmt.nil?
      #   @dst_format
      # end
      # 
      # def executable( executable_name = nil )
      #   @executable_name = executable_name unless executable_name.nil?
      #   @executable_name
      # end
      
      def is_executable_installed?
        @executable && `which #{executable}`.strip.fwf_blank? == false
      end
        #     
        # def command( cmd = nil )
        #   @command = cmd unless cmd.nil?
        #   @command ||= "{{x}} {{opts}} '{{src}}' '{{dst}}'"   # default
        # end
        #      
        
      # opts {
      #    :dest => Destination (output) file,
      #    :command_line_options =>  Arguments to feed to the executable. Just a string, replaces the {{o}} in @command
      # } 
      def convert( src, opts = {} )
        src = src.fwf_filepath
        dst = opts[:dest].is_a?(String) ? opts[:dest].fwf_filepath : opts[:dest]

        if dst.nil? 
          dst = src.gsub( /#{@input_format}$/, @output_format.to_s )
        end
        
        if is_executable_installed?
          if src.file?
            cmd = command.gsub("{{x}}", executable.to_s).gsub("{{o}}", opts[:command_line_options]).gsub("{{src}}", src).gsub("{{dst}}", dst)
            puts "running command : #{cmd}"
            
            

            `#{cmd}`
            $?.success?
          else
            warn( "Source file #{src} does not exist.".paint(:red,:bold))
            false
          end
        else
          false
        end
      end
    end
  end
end