module EpubForge
  module Epub
    class Stylesheet
      attr_accessor :filename, :name, :contents
      def initialize( filename )
        @filename = filename
        @name = File.basename( @filename )
        @contents = File.read( @filename )
      end
    end
  end
end