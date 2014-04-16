module EpubForge
  module Action
    class FileTransformer
      attr_reader :original_filename, :transformed_filename
      def initialize( file )
        @original_filename = file
        @transformed_filename = "#{@original_filename}.epubforge.#{sprintf("%07i", rand(1000000))}.tmp"
        @out = File.open( @transformed_filename, "w" )
        @finished = false
      end
  
      def finalize
        return if finished?
        @finished = true
        @out.close
    
        FileUtils.mv( @transformed_filename, @original_filename )
      end
  
      def abort
        return if finished?
        @finished = true
        FileUtils.rm( @transformed_filename )
      end
  
      def write( input )
        return if finished?
        @out << input
        @out.flush
      end
  
      def <<( input )
        write( input )
      end
  
      def read_file
        File.read( @original_filename )
      end
  
      def readlines( &block )
        File.readlines( @original_filename ) do |line|
          yield line
        end
      end
  
      def old_size
        File.size?( @original_filename )
      end
  
      def new_size
        File.size?( @transformed_filename )
      end
  
      def finished?
        @finished
      end
    end
  end
end