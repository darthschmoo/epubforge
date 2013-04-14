module EpubForge
  module Utils
    class FilePath < Pathname
      def initialize( *args )
        super( File.join( *args ) )
      end

      # args implicitly joined to cwd
      def self.cwd( *args )
        Dir.pwd.epf_filepath.join( *args )
      end
      
      def self.pwd( *args )
        self.cwd( *args )
      end

      def join( *args, &block )
        if block_given?
          yield self.class.new( super(*args) )
        else
          self.class.new( super(*args) )
        end
      end

      alias :exists? :exist?
      
      def up
        self.class.new( self.join("..") ).expand
      end
      
      # opts:
      #    :class  =>  [self.class] The class of objects you want returned (String, FilePath, ClassLoader, etc.)
      #                Should probably be a subclass of FilePath or String.  Class.init must accept a string
      #                [representing a file path] as the sole argument.
      #
      #    :recurse => [false] 
      #    :ext => []  A single symbol, or a list containing strings/symbols representing file name extensions.
      #                No leading periods kthxbai.
      #     
      #    If opts not given, the user can still do it explicitly with arguments like .glob("**", "*.rb")           
      def glob( *args )
        opts = args.last.is_a?(Hash) ? args.pop : {}
        
        recurser = opts[:recurse] ? "**" : nil
        extensions = case opts[:ext]
        when Symbol, String
          "*.#{opts[:ext]}"
        when Array
          extensions = opts[:ext].map(&:to_s).join(',')
          "*.{#{extensions}}"
        when NilClass
          nil
        end
        
        args += [recurser, extensions]
        args.compact!
        
        opts[:class] ||= self.class
        Dir.glob( self.join(*args) ).map{ |f| opts[:class].new(f) }
      end
      
      def expand
        self.class.new( File.expand_path( self ) )
      end

      def touch
        FileUtils.touch( self )
        return true
      rescue Errno::EACCESS
        return false
      end
      
      def touch_dir
        FileUtils.mkdir_p( self )
        return true
      rescue Errno::EEXIST
        return true
      rescue Errno::EACCESS
        return false
      end
      
      def write( content = nil, &block )
        File.open( self, "w" ) do |f|
          f << content if content
          if block_given?
            yield f
          end
        end
      end
      
      def append( content = nil, &block )
        File.open( self, "a" ) do |f|
          f << content if content
          if block_given?
            yield f
          end
        end
      end
      
      def grep( regex )
        return [] unless self.file?
        matching = []
        self.each_line do |line|
          matching.push( line ) if line.match( regex )
        end
        matching
      end

      # Not the same as zero?
      def empty?
        raise Exceptions::FileDoesNotExist unless self.exist?
        
        if self.file?
          File.size( self ) == 0
        elsif self.directory?
          self.glob( "**", "*" ).length == 0
        end
      end
      
      def basename_no_ext
        self.basename.to_s.split(".")[0..-2].join(".").epf_filepath
      end
      
      def without_ext
        self.gsub(/\.#{self.ext}$/, '')
      end
      
      def ext
        self.basename.to_s.split(".").last || ""
      end
      
      def relative_to( ancestor_dir )
        depth = ancestor_dir.to_s.split(File::SEPARATOR).length
        relative_path = self.to_s.split(File::SEPARATOR)
        relative_path[(depth)..-1].join(File::SEPARATOR).epf_filepath
      end
      
      def gsub( *args )
        self.to_s.gsub(*args).epf_filepath
      end
      
      def gsub!( *args )
        new_str = self.to_s.gsub(*args)
        self.instance_variable_set(:@path, new_str)
      end
      
      def epf_filepath
        self
      end
    end
  end
end