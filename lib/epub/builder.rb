# Avoiding namespace collision.
XmlBuilder = Builder

module EpubForge
  module Epub
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
      
      def initialize project, opts = {}
        puts "--------------- forgin' #{project.filename_for_epub_book} ------------------"
        @project = project
        @config  = project.config
        @book_dir_short = opts[:book_dir] ? opts[:book_dir].split.last.to_s : "book"
        @book_dir = @project.target_dir.join( @book_dir_short ).fwf_filepath.expand
        @config = @project.config
        
        @config.page_orderer = Utils::FileOrderer.new( opts[:page_order] || @config.pages[@book_dir_short] )

        @metadata = @config.metadata || {}
        
        page_files = @book_dir.glob( ext: PAGE_FILE_EXTENSIONS ) 
        @section_files = @config.page_orderer.reorder( page_files )
        
        @sections = @section_files.map do |section|
          case section.to_s.split(".").last
          when "markdown"
            Assets::Markdown.new( section, @metadata, self ) 
          when "html"
            Assets::HTML.new( section, @metadata, self )
          when "textile"
            Assets::Textile.new( section, @metadata, self )
          when "xhtml"
            Assets::XHTML.new( section, @metadata, self )  # These files are inserted into the book unaltered
          else
            raise "UNKNOWN EXTENSION TYPE"
          end
        end
        
        # @sections.each_with_index{ |sec, i| sec.section_number = i }

        images = @book_dir.glob( "images", ext: IMAGE_FILE_EXTENSIONS )
        @images = images.map{ |img| Assets::Image.new(img) }

        @stylesheets = @book_dir.glob( "stylesheets", "*.css" ).map do |sheet| 
          Assets::Stylesheet.new( sheet ) 
        end
        
        @fonts = @book_dir.glob( "fonts", ext: FONT_FILE_EXTENSION ).map do |font|
          Assets::Font.new( font )
        end
    
        install_cover
        
        @scratch_dir = FunWith::Files::FilePath.tmpdir.join( "ebookdir" )
      end
      
      def install_cover
        # Existing cover is moved to the very front
        if @cover_section = @sections.detect(&:cover?)
          # no need to do anything
        elsif @cover_image = @images.detect(&:cover?)
          # actually install cover
          contents = "<div id='cover'><img class='cover' src='#{@cover_image.link.relative_path_from(TEXT_DIR)}' alt='#{@metadata.name}, by #{@metadata.author}'/></div>"
          cover_file = @project.book_dir.join( "cover.xhtml" )
          cover_file.write( wrap_page( contents ) )
          @cover_section = Assets::Page.new( cover_file, @metadata, @project )
          @sections.unshift( @cover_section )
          puts "cover page generated"
        else
          return false
        end
      end

      def toc
        b = XmlBuilder::XmlMarkup.new(:indent => 2)
        b.instruct!     # <?xml version="1.0" encoding="UTF-8"?>
        b.declare! :DOCTYPE, :ncx, :PUBLIC, "-//NISO//DTD ncx 2005-1//EN", "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" # <!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN"

        # <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
        b.ncx :xmlns => "http://www.daisy.org/z3986/2005/ncx/", :version => "2005-1" do
          #     <head>
          #         <meta name="dtb:uid" content="58cf98c8-e5be-416d-8ce8-ceae573d5ac5"/>
          #         <meta name="dtb:depth" content="1"/>
          #         <meta name="dtb:totalPageCount" content="0"/>
          #         <meta name="dtb:maxPageNumber" content="0"/>
          #     </head>
          b.head do
            b.meta :name => "dtb:uid", :content => "58cf98c8-e5be-416d-8ce8-ceae573d5ac5"
            b.meta :name => "dtb:depth", :content => "1"
            b.meta :name => "dtb:totalPageCount", :content => "0"
            b.meta :name => "dtb:maxPageNumber", :content=> "0"

          end
      
          #     <docTitle>
          #         <text>#{PROJECT_NAME}</text>
          #     </docTitle>
          b.docTitle do
            b.text @metadata["name"]
          end
      
          #     <navMap>
          b.navMap do
            @sections.each_with_index do |section,i|
              # <navPoint id="navPoint-#{i}" playOrder="#{i}">
              #     <navLabel>
              #         <text>#{section.title}</text>
              #     </navLabel>
              #     <content src="Text/section#{sprintf("%04i",i)}.xhtml"/>
              # </navPoint>
              b.navPoint :id => "navPoint-#{i}", :playOrder => "#{i}" do
                b.navLabel do
                  b.text section.title
                end
                b.content :src => section.link.relative_path_from( "/OEBPS" )
              end
            end
          end
        end

    
        b.target!.to_s
      end
    
      def mimetype
        "application/epub+zip"
      end  
  
      def container
        b = XmlBuilder::XmlMarkup.new(:indent => 2)
    
        # <?xml version="1.0"?>
        b.instruct!
        # <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        #     <rootfiles>
        #         <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
        #    </rootfiles>
        # </container>
        b.container :version => "1.0", :xmlns => "urn:oasis:names:tc:opendocument:xmlns:container" do
          b.rootfiles do
            b.rootfile :"full-path" => "OEBPS/content.opf", :"media-type" => "application/oebps-package+xml"
          end
        end
      end

      def content_opf
        b = XmlBuilder::XmlMarkup.new(:indent => 2)
    
        # <?xml version="1.0" encoding="UTF-8"?>
        b.instruct!
    
        # <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookID" version="2.0">
        b.package :xmlns => "http://www.idpf.org/2007/opf", "unique-identifier" => "BookID", :version => "2.0" do
          # <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
          b.metadata :"xmlns:dc" => "http://purl.org/dc/elements/1.1/", :"xmlns:opf" => "http://www.idpf.org/2007/opf" do
            #     <dc:title>#{PROJECT_NAME}</dc:title>
            #     <dc:creator opf:role="aut">#{PROJECT_AUTHOR}</dc:creator>
            #     <dc:language>en-US</dc:language>
            #     <dc:identifier id="BookID" opf:scheme="UUID">urn:uuid:58cf98c8-e5be-416d-8ce8-ceae573d5ac5</dc:identifier>
            # 
            #     <dc:rights>Creative Commons Non-commercial No Derivatives</dc:rights>
            #     <dc:publisher>Lulu.com</dc:publisher> 
            #     <dc:date opf:event="original-publication">2012</dc:date>
            #     <dc:date opf:event="epub-publication">2012</dc:date>
            # 
            b.dc :title, @metadata["name"]
            b.dc :creator, {:"opf:role" => "aut"}, @metadata["author"]
            b.dc :language, "en-US"
            b.dc :identifier, {:id => "BookID", "opf:scheme" => "UUID"}, "urn:uuid:58cf98c8-e5be-416d-8ce8-ceae573d5ac5"  #TODO Unique id generator
            b.dc :rights, @metadata["license"]
            b.dc :publisher, @metadata["publisher"] || "A Pack of Orangutans"
            b.dc :date, {:"opf:event" => "original-publication"}, @metadata["original-publication"] || Time.now.year
            b.dc :date, {:"opf:event" => "epub-publication"}, @metadata["epub-publication"] || Time.now.year
            
            
            if @cover_section
              b.meta :name => "cover", :content => "cover"
            end
          end
      
          # <manifest>
          b.manifest do
            #     <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            b.item :id => "ncx", :href => "toc.ncx", :"media-type" => "application/x-dtbncx+xml"
            
            [@sections, @images, @stylesheets, @fonts].flatten.each do |asset|
              b.item :id => asset.item_id, :href => asset.link.relative_path_from("/OEBPS"), :"media-type" => asset.media_type
            end
          end
      
          # <spine toc="ncx"> 
          b.spine :toc => "ncx" do
            @sections.each do |section|
              b.itemref :idref => section.item_id
            end
          end
      
          # TODO: <guide> section
          # <guide>
          #   <reference type="title-page" title="Title Page"        
          #            href="Text/title_page.xhtml" />
          #   <reference type="cover" title="Cover" href="Text/cover.xhtml"/>
          #   <reference type="text"       title="Text"              
          #            href="Text/chapter0001.xhtml" />
          # </guide>
        end
    
        b.target!.to_s
      end
   
      # zips up contents
      def build
        Utils::DirectoryBuilder.create( @scratch_dir ) do |build|
          
          build.file( "mimetype", mimetype )
          
          build.dir( "META-INF" ) do
            build.file("container.xml", container)
          end
          
          build.dir( "OEBPS" ) do
            build.file( "toc.ncx", toc )
            build.file( "content.opf", content_opf )
            
            build.dir( "Text" ) do
              @sections.each do |section|
                build.file( section.dest_filename, 
                            section.is_a?( Assets::XHTML ) ? section.html : wrap_page( section.html )
                          )
              end
            end
          
            unless @images.epf_blank?
              build.dir "Images" do
                for img in @images
                  build.copy( img.filename )
                end
              end
            end
          
            unless @stylesheets.epf_blank?
              build.dir "Styles" do
                for sheet in @stylesheets
                  build.file( sheet.name, sheet.contents )
                end
              end
            end
            
            unless @fonts.epf_blank?
              build.dir "Fonts" do
                for font in @fonts
                  build.copy( font.filename )
                end
              end
            end
          end
        end
      end
  
      def package epub_filename
        Packager.new( @scratch_dir, epub_filename ).package
      end
      
      def clean
        # do nothing
      end

      protected      
      def wrap_page content = ""
        b = XmlBuilder::XmlMarkup.new( :indent => 2)
        b.instruct! :xml, :encoding => "utf-8", :standalone => "no"
        b.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
  
        b.html :xmlns => "http://www.w3.org/1999/xhtml" do
          b.head do 
            b.title( @metadata["name"] )
            for sheet in @stylesheets
              b.link :href => sheet.link.relative_path_from("/OEBPS/Text"), :media => "screen", :rel => "stylesheet", :type => "text/css"
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