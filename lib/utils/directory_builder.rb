module EpubForge
  module Utils
    class DirectoryBuilder
      attr_accessor :current_path, :current_file
      
      def initialize( path )
        @paths = []
        @current_path = path.epf_filepath
        make_path
      end
      
      def self.create( path, &block )
        builder = self.new( path )
        yield builder if block_given?
        builder
      end
      
      def dir( *args, &block )
        descend( *args ) do
          yield if block_given?
        end
      end
      
      # block must be given
      def self.tmpdir( &block )
        if block_given?
          Dir.mktmpdir do |dir|
            self.create( dir ) do |builder|
              yield builder
            end
          end
        else
          self.create( Dir.mktmpdir )
        end
      end
      
      # Copies the given source file into a file in the current_path.
      # If a dest_name is given, the new file will be given that name.
      def copy( src_filepath, dst_name = nil )
        dst_filepath = dst_name ? @current_path.join( dst_name ) : @current_path
        FileUtils.copy( src_filepath, dst_filepath )
      end
      
      def file( name = nil, content = nil, &block )
        # if name && content
        #   begin
        #     f = open_file( name )
        #     f << content
        #   ensure
        #     close_file
        #   end
        if name
          open_file( name )
          @current_file << content if content
          if block_given?
            begin
              yield @current_file
            ensure
              close_file
            end
          end
        else
          @current_file
        end
      end
      
      def current_file
        @current_file ? FilePath.new( @current_file.path ) : nil
      end
      
      # if file not given, the result is appended to the current file.
      def download( url, file = nil )
        if file
          if file.epf_filepath.relative?
            file = FilePath.new( @current_path, file )
          end
            
          File.open( file, "w" ) do |f|
            download_to_target( url, f )
          end
        elsif @current_file
          download_to_target( url, @current_file )
        else
          puts "No current file to append #{url} to."
        end
      end

      def template( src, dst, vars = {} )
        self.file( dst ) do |f|
          f << Utils::TemplateEvaluator.new( src, vars ).result
        end
      end
      
      protected
      def make_path
        FileUtils.mkdir_p( @current_path ) unless @current_path.exist?
      end

      def descend( *args, &block )
        if @current_path.directory?
          close_file
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
        if @current_file
          @current_file.flush
          @current_file.close
        end
        
        @current_file = nil
      end
      
      def download_to_target( url, file )
        Downloader.new.download( url, file )
      end
    end
  end
end


# sample code
# 
# DirBuilder.create( '~/project' ) do |b|         # starts by creating directory.  If parent 
#                                                 # directories don't exist, they will soon.
#                                                 # if you use DirBuilder.tmp('~/project'), a tempdir
#                                                 # is created, and its contents relocated to ~/project when the
#                                                 # block terminates.
#   b.dir("images") do                      # creates subdirectory "images"
#     for img in src_dir.entries.select{|img| img.extension == ".png"}
#     b.copy( src_dir.join( img.filename ) )         # copies a bunch of files from another directory
#   end    # rises back to the initial '~/project directory
# 
#   b.copy( src_dir.join( "rorshach.xml" ) )
#   b.download( "dest.bash", "http://get.rvm.io" )            # downloads file directly beneath '~/project'
#                                                             # maybe someday, though
# 
#   b.dir("text", "scenes") do   # creates ~/project/text/scenes subdir
#     b.file( "adventure_time.txt" ) do |f|
#       f << "Fill this in later"
#     end
# 
#     # calling .file without feeding it a block leaves it open for writing,
#     # until either the enclosing block terminates or .file is called
#     # again with a string argument.
#     b.file( "another_brick.txt" )           
#     b.file << "Hey, you!"
#     b.file << "Yes, you!"
#     b.file.push "Stand still, laddie!"
#     
#     b.template(templates_dir.join("blue_template.txt")) do |t|
#       t.var(:fname, "John")
#       t.var(:lname, "Macey")
#       t.var(:state, "Ohio")
#       t.vars(graduated: "2003")
#       t.vars(quot: "That wasn't my duck.", photo: "john.png", css: "font-family: arial")
#     end
# 
#     b.copy( [src_dir.join("abba.txt"), "baab.txt"] )  # contents of abba.txt copied into baab.txt
#   
#     
#     b.file( ".lockfile" )   # creates an empty file
#   end
# 
#   b.
# end
#   
  
