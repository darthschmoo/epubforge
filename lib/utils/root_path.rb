module EpubForge
  module Utils
    module RootPath
      def root( *args )
        if args.length > 0
          args.unshift( @root_path )
          FilePath.new( *args )
        else
          FilePath.new( @root_path )
        end
      end
      
      def set_root_path( path )
        @root_path = FilePath.new( path )
      end
    end
  end
end

EpubForge.extend EpubForge::Utils::RootPath
