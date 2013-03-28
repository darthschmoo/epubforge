module EpubForge
  module Page
    class HTML < AbstractPage
      
      # [TODO: Doesn't handle metadata at all.]
      def self.html_page_for file, metadata, project
        content = File.read( file )
        content
      end
    end
  end
end