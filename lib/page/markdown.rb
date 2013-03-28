module EpubForge
  module Page
    class Markdown < AbstractPage
      def self.html_page_for file, metadata, project
        content = `multimarkdown "#{file}"`
        wrap_contents( content, metadata )
      end

      protected
      def self.wrap_contents content, metadata = {}
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
        b.instruct! :xml, :encoding => "utf-8", :standalone => "no"

        b.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"

        b.html :xmlns => "http://www.w3.org/1999/xhtml" do
          b.head do 
            b.title metadata["name"]
            for sheet in (metadata["stylesheets"] || [])
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