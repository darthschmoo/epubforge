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

      def join( *args )
        self.class.new( super(*args) )
      end

      alias :exists? :exist?
      
      def up
        self.class.new( self.join("..") ).expand
      end
      
      def glob( *args )
        Dir.glob( self.join(*args) ).map{ |f| self.class.new(f) }
      end
      
      def expand
        self.class.new( File.expand_path( self ) )
      end

      def touch
        `touch #{self.expand}`
        raise "File does not exist or is not writable: #{filename}" if $? != 0
        
        self
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
      
      def epf_filepath
        self
      end
    end
  end
end