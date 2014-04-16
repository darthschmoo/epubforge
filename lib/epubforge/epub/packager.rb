module EpubForge
  module Epub
    class Packager
      def initialize( src_dir, dst_filename )
        @src_dir = src_dir
        @dst_filename = dst_filename
      end
      
      def package
        @dst_filename = @dst_filename.expand
        FileUtils.rm( @dst_filename ) if @dst_filename.exist?
        `cd #{@src_dir} && zip -Xr #{@dst_filename.to_s.epf_backhashed_filename} mimetype META-INF OEBPS`
      end
    end
  end
end