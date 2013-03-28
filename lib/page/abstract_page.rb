module EpubForge
  module Page
    class AbstractPage
      attr_reader :html, :original_file, :title, :project

      def initialize file, metadata, project
        raise "NIL" if project.nil?
        
        @metadata = metadata
        @project  = project
        @original_file = file
        puts self.class.name
        @html = self.class.html_page_for( file, @metadata, @project )
        @title = File.basename( file ).split(".")[0..-1].map(&:capitalize).join(" : ")
        puts "Initialized #{file} with title [#{@title}]"
      end
      
      def html_page_for file, metadata
        wrap_contents( "ERROR: Abstract page called.", metadata )
      end
      
      protected
      def wrap_contents content, metadata = {}
        #   out = <<-END
        # <?xml version="1.0" encoding="utf-8" standalone="no"?>
        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
        #   "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
        #   
        #   <html xmlns="http://www.w3.org/1999/xhtml">
        #   <head>
        #     <title>#{PROJECT_NAME}</title>
        #     <link href="../Styles/style.css" media="screen" rel="stylesheet" type="text/css" />  
        #   </head>
        # 
        #   <body>
        #     #{content}
        #   </body>
        # </html>
        b = Builder::XmlMarkup.new(:indent => 2)
        b.instruct! :xml, :version => "utf-8", :standalone => "no"
    
        b.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
    
        b.html :xmlns => "http://www.w3.org/1999/xhtml" do
          b.head do 
            b.title metadata["name"]
            
            for sheet in @project.stylesheets
              b.link :href => "../Styles/#{sheet.name}", :media => "screen", :rel => "stylesheet", :type => "text/css"
            end
          end
      
          b.body do
            b << content
          end
        end
    
        b.target!.to_s
      end
    end
  end
end