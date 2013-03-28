module EpubForge
  module Exceptions
    class FileError < Exception; end
    class FileDoesNotExist < FileError; end
    class FileMustNotExist < FileError; end
  end
  
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

      # def join( *args )
      #   (args.length > 0) ? self.class.new( File.join( self, *args ) ) : self
      # end

      alias :exists? :exist?
      
      # def exist?
      #   File.exist?( self )
      # end
      # 
      # def basename
      #   self.class.new( File.basename( self ) )
      # end
      # 
      # def dirname
      #   self.class.new( File.dirname( self ) )
      # end
      
      def up
        self.class.new( self.join("..") ).expand
      end
      
      def glob( *args )
        Dir.glob( self.join(*args) ).map{ |f| self.class.new(f) }
      end
      
      def expand
        self.class.new( File.expand_path( self ) )
      end
      
      # def read( *args )
      #   File.open( self, "r" ).read( *args )
      # end

      def touch
        `touch #{self.expand}`
        self
      end
      
      # def file?
      #   File.file?( self )
      # end
      # 
      # def directory?
      #   File.directory?( self )
      # end

      # Not the same as zero?
      def empty?
        raise Exceptions::FileDoesNotExist unless self.exist?
        
        if self.file?
          File.size( self ) == 0
        elsif self.directory?
          self.glob( "**", "*" ).length == 0
        end
      end
    end
  end
end