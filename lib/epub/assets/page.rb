module EpubForge
  module Epub
    module Assets
      class Page < Asset
        attr_reader :html, :original_file, :title, :project

        def initialize file, metadata, project
          raise "NIL" if project.nil?
        
          @metadata = metadata
          @project  = project
          @original_file = file

          @html = self.class.html_page_for( file, @metadata, @project )
          @title = File.basename( file ).split(".")[0..-2].map(&:capitalize).join(" : ")
          @content = ""
          puts "Initialized #{file} with title [#{@title}]"
        end
      
        def self.html_page_for file, metadata, project
          @content = Utils::Htmlizer.htmlize( file )
          self.wrap_contents( @content, metadata, project )
        end
      
        protected      
        def self.wrap_contents content, metadata, project
          b = Builder::XmlMarkup.new( :indent => 2)
          b.instruct! :xml, :encoding => "utf-8", :standalone => "no"
          b.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
    
          b.html :xmlns => "http://www.w3.org/1999/xhtml" do
            b.head do 
              b.title( metadata["name"] )
              for sheet in project.stylesheets
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
end