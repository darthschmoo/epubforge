module EpubForge
  module Utils
    class Htmlizer
      GROUP_NAMES = [:preferred, :user, :default, :fallback]
      
      def self.init_class
        @exec_location = {}
        
        @htmlizers = {} 
        
        @htmlizers[:all] = []
        @htmlizers[:named] = {}
      end
      init_class
      
      def self.location( name, path = nil )
        @exec_location[name] = path if path
        @exec_location[name]
      end
      
      def self.htmlizers
        @htmlizers
      end
      
      # Returns them in a rough priority order, user-defined ones first.
      def self.handling_format( requested_format )
        htmlizers = GROUP_NAMES.map{ |group|
          (@htmlizers.keys - [:all, :named]).map do |format|
            htmlizers = @htmlizers[format][group]
            htmlizers ? htmlizers.select{|html| html.handles_format?(requested_format) } : []
          end
        }
        
        htmlizers.flatten
      end
      
      def self.named( name )
        @htmlizers[:named][name]
      end
      
      # def self.htmlizer( fmt, name = :any )
      #   htmlizers = @htmlizers[fmt]
      #   if name == :any
      #     htmlizers.values.flatten
      #   else
      #     htmlizers[name] || []
      #   end
      # end
      
      def self.define( &block )
        htmlizer = self.new
        yield htmlizer
        
        categorize( htmlizer )
      end
      
      protected
      def self.categorize( htmlizer )
        @htmlizers[:all] << htmlizer
        @htmlizers[:named][htmlizer.name] = htmlizer if htmlizer.name

        @htmlizers[htmlizer.format] ||= {}
        @htmlizers[htmlizer.format][htmlizer.group] ||= []
        @htmlizers[htmlizer.format][htmlizer.group] << htmlizer
      end
      
      # available options
      # :htmlizer => the sym for the requested htmlizer.  
      # :opts     => a string representing options to execute cmd with
      public
      def self.htmlize( filename, opts = {} )
        htmlizer  = opts[:htmlizer] 
        htmlizer  = @htmlizers[:named][htmlizer]
        opts      = opts[:opts] || ""
        
        if htmlizer
          if result = htmlizer.htmlize( filename, {opts: opts } )
            return result
          else
            puts "Named Htmlizer #{htmlizer} did not return html. Falling back on other htmlizers"
          end
        end
        # 
        format = format_from_filename( filename )
      
        for htmlizer in self.handling_format(format)
          puts "Trying htmlizer #{htmlizer.format} #{htmlizer.group} on #{filename}"
          if result = htmlizer.htmlize( filename, opts )
            return result
          end
        end
        
        "<!-- COULD NOT FIND HTMLIZER FOR #{filename} -->"
      end
      
      def self.format_from_filename( filename )
        ext = filename.epf_filepath.extname.gsub(/^\./, "")
        ext.epf_blank? ? :unknown : ext.to_sym
      end
      
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
          @executable_name = self.class.location( executable_name ) || `which #{executable_name}`.strip
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
      
      def opts o = nil
        @opts = o if o
        @opts
      end
      
      def installed?
        executable.length > 0
      end
      
      def handles_format?( f )
        @format == f && installed?
      end
      
      def htmlize( filename, opts = "" )
        return false unless installed?
        
        exec_string = cmd.gsub( /\{\{f\}\}/, filename.to_s )
        opts = @opts if opts.epf_blank?
        exec_string.gsub!( /\{\{o\}\}/, opts  )
        exec_string.gsub!( /\{\{x\}\}/, executable  )
        # resulting html
        result = "<!-- generated from #{@format} by htmlizer #{@name} -->\n\n" + `#{exec_string}`
        puts result
        result
      end
    end
  end
end
