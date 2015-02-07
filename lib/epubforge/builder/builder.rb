# Avoiding namespace collision.
XmlBuilder = Builder

# Coaxing the project into a sort of universal format.  The parent class handles the 
module EpubForge
  module Builder
    PAGE_FILE_EXTENSIONS  = %w(html markdown textile xhtml)
    IMAGE_FILE_EXTENSIONS = %w(jpg png gif)
    FONT_FILE_EXTENSION   = %w(ttf otf)

    MEDIA_TYPES = { "gif" => "image/gif", "jpg" => "image/jpeg", "png" => "image/png",
                    "css" => "text/css", "js" => "application/javascript", "pdf" => "application/pdf",
                    "txt" => "text/plain", "xhtml" => "application/xhtml+xml",
                    "ttf" => "application/x-font-ttf", "otf" => "application/x-font-opentype"
                  }
    
    IMAGE_DIR, STYLE_DIR, TEXT_DIR, FONT_DIR = %w(Images Styles Text Fonts).map{ |dir| 
      "/".fwf_filepath.join("OEBPS", dir) 
    }
        
    class Builder
      attr_reader :stylesheets
      attr_reader :project
      attr_reader :sections
      
      def initialize project, opts = {}
        target_file = opts[:target_file] || project.filename_for_book.ext("epub")  # TODO: But what about notes?
        
        # puts "--------------- forgin' #{ target_file } ------------------"

        @project = project
        @config  = project.config
        @book_dir_short = opts[:book_dir] ? opts[:book_dir].split.last.to_s : "book"
        @book_dir = @project.root_dir.join( @book_dir_short )   # TODO: .expand?

        @config.page_orderer = Utils::FileOrderer.new( opts[:page_order] || @config.pages[@book_dir_short] )

        @metadata = @config.metadata || {}
        
        
        initialize_page_assets
        initialize_image_assets
        initialize_stylesheet_assets
        initialize_font_assets
        install_cover
        
        @scratch_dir = FunWith::Files::FilePath.tmpdir.join( "ebookdir" )
      end
      
      def initialize_page_assets
        page_files = @book_dir.glob( ext: PAGE_FILE_EXTENSIONS )
        @section_files = @config.page_orderer.reorder( page_files )
        
        @sections = @section_files.map do |section|
          case section.to_s.split(".").last
          when "markdown", "html", "textile", "xhtml"
            Assets::Page.new( section, @metadata, self )
          #   Assets::Markdown.new( section, @metadata, self ) 
          # when "html"
          #   Assets::HTML.new( section, @metadata, self )
          # when "textile"
          #   Assets::Textile.new( section, @metadata, self )
          # when "xhtml"
          #   Assets::XHTML.new( section, @metadata, self )  # These files are inserted into the book unaltered
          else
            raise "UNKNOWN EXTENSION TYPE"
          end
        end
      end
      
      def initialize_image_assets
        images = @book_dir.glob( "images", ext: IMAGE_FILE_EXTENSIONS )
        @images = images.map{ |img| Assets::Image.new(img) }
      end
      
      def initialize_stylesheet_assets
        @stylesheets = @book_dir.glob( "stylesheets", "*.css" ).map do |sheet| 
          Assets::Stylesheet.new( sheet ) 
        end
      end
      
      def initialize_font_assets
        @fonts = @book_dir.glob( "fonts", ext: FONT_FILE_EXTENSION ).map do |font|
          Assets::Font.new( font )
        end
      end
          
      
      def install_cover
        # Existing cover is moved to the very front
        if @cover_section = @sections.detect(&:cover?)
          # no need to do anything
        elsif @cover_image = @images.detect(&:cover?)
          # actually install cover
          contents = "<div><img class='cover' src='#{@cover_image.link.relative_path_from(TEXT_DIR)}' alt='#{@metadata.name}, by #{@metadata.author}'/></div>"
          cover_file = @project.book_dir.join( "cover.xhtml" )
          cover_file.write( wrap_page( contents, "cover" ) )
          @cover_section = Assets::Page.new( cover_file, @metadata, @project )
          @sections.unshift( @cover_section )
          puts "cover page generated"
        else
          return false
        end
      end

   
  
      protected      
      
      # Useful for multiple builders
      # body_id provides a section-specific hook for CSS customizing.
      def wrap_page( content = "", body_id = "body_class" )
        b = XmlBuilder::XmlMarkup.new( :indent => 2)
        b.instruct! :xml, :encoding => "utf-8", :standalone => "no"
        b.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
  
        b.html :xmlns => "http://www.w3.org/1999/xhtml" do
          b.head do 
            b.title( @metadata["name"] )
            for sheet in @stylesheets
              b.link :href => sheet.link.relative_path_from("/OEBPS/Text"), :media => "all", :rel => "stylesheet", :type => "text/css"
            end
          end
    
          
          b.body( :id => body_id ) do
            b << content
          end
        end
  
        b.target!.to_s
      end
    end
  end
end