module EpubForge
  module Utils
    class DirBuilder
      def initializer( path )
        @paths = []
        @current_path = path.epf_filename
        make_path
      end
      
      def self.create( path, &block )
        builder = self.new( path )
        yield builder if block_given?
        builder.path
      end
      
      def dir( *args, &block )
        descend( *args ) do
          yield if block_given?
        end
      end
      
      def self.tmpdir( &block )
        Dir.mktmpdir do |d|
          self.create( d, &block )
        end
      end
      
      def copy( *args )
        for arg in args
          FileUtils.copy( arg, @current_path )
        end
      end
      
      def file( name = nil, &block )
        if name
          open_file( name )
          if block_given?
            yield @current_file
            close_file
          end
        else
          @current_file
        end
      end

      protected
      def make_path
        FileUtils.mkdir_p( @current_path ) unless @current_path.exist?
      end

      def descend( *args, &block )
        if @current_path.directory?
  	      @paths << @current_path
          @current_path = @paths.last.join( *args )
          make_path
  	      yield
          @current_path = @paths.pop
          close_file
        else
          raise "Cannot descend."
        end
      end 
      
      def open_file( name )
        close_file
        @current_file = File.open( @current_path.join( name ), "w" )
      end
      
      def close_file
        @current_file.close if @current_file
        @current_file = nil
      end
    end
  end
end


sample code

DirBuilder.create( '~/project' ) do |b|         # starts by creating directory.  If parent 
                                                # directories don't exist, they will soon.
                                                # if you use DirBuilder.tmp('~/project'), a tempdir
                                                # is created, and its contents relocated to ~/project when the
                                                # block terminates.
  b.dir("images") do                      # creates subdirectory "images"
    for img in src_dir.entries.select{|img| img.extension == ".png"}
    b.copy( src_dir.join( img.filename ) )         # copies a bunch of files from another directory
  end    # rises back to the initial '~/project directory

  b.copy( src_dir.join( "rorshach.xml" ) )
  b.download( "dest.bash", "http://get.rvm.io" )            # downloads file directly beneath '~/project'
                                                            # maybe someday, though

  b.dir("text", "scenes") do   # creates ~/project/text/scenes subdir
    b.file( "adventure_time.txt" ) do |f|
      f << "Fill this in later"
    end

    # calling .file without feeding it a block leaves it open for writing,
    # until either the enclosing block terminates or .file is called
    # again with a string argument.
    b.file( "another_brick.txt" )           
    b.file << "Hey, you!"
    b.file << "Yes, you!"
    b.file.push "Stand still, laddie!"
    
    b.template(templates_dir.join("blue_template.txt")) do |t|
      t.var(:fname, "John")
      t.var(:lname, "Macey")
      t.var(:state, "Ohio")
      t.vars(graduated: "2003")
      t.vars(quot: "That wasn't my duck.", photo: "john.png", css: "font-family: arial")
    end

    b.
  
    
    b.file( ".lockfile" )   # creates an empty file
  end

  b.
end
  
  
class Downloader
  # stolen from:
  # http://stackoverflow.com/questions/2263540/how-do-i-download-a-binary-file-over-http-using-ruby
  File.open(filename,'w'){ |f|
    uri = URI.parse(url)
    Net::HTTP.start(uri.host,uri.port) do |http| 
      http.request_get(uri.path) do |res| 
        res.read_body do |seg|
          f << seg
  #hack -- adjust to suit:
          sleep 0.005 
        end
      end
    end
  end
end

