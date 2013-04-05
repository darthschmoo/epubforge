# Avoiding namespace collision.
XmlBuilder = Builder

module EpubForge
  module Epub
    class Builder
      PAGE_FILE_EXTENSIONS  = %w(html markdown)
      IMAGE_FILE_EXTENSIONS = %w(jpg png gif)
  
      attr_reader :stylesheets
      
      # Class user responsible for giving EpubBuilder the sections in the 
      # proper order of appearance
      def initialize book_dir, config = {}    
        puts "--------------- forgin' #{book_dir} ------------------"
        @book_dir = book_dir
        @config = config
        @config["pages"] ||= {}
        @metadata = @config["metadata"] || {}
        files = []
        
        for ext in PAGE_FILE_EXTENSIONS
          files.concat Dir[ File.join( @book_dir, "*.#{ext}" ) ]
        end
        
        preordered_files = @config["pages"].map{ |f| File.join( book_dir, "#{f}.markdown" ) }

        files_in_desired_order = preordered_files + ( files - preordered_files )

        images = IMAGE_FILE_EXTENSIONS.inject([]){ |memo, extension|
          memo.concat Dir[ File.join( @book_dir, "images", "*.#{extension}" ) ]
        }
        
        stylesheets = Dir[ File.join( @book_dir, "stylesheets", "*.css" ) ]
        @stylesheets = stylesheets.map{ |file| Stylesheet.new( file ) }
    
        @section_files = files_in_desired_order
        @images = images.map{ |img| Image.new(img) }
    
        @sections = @section_files.map{ |section|
          case section
          when /\.markdown$/
            Page::Markdown.new( section, @metadata, self ) 
          when /\.html$/
            Page::HTML.new( section, @metadata, self )
          else
            raise "UNKNOWN EXTENSION TYPE"
          end
        }

        @build_dirs = []
        @scratch_dir = File.join("/tmp", "epubforge.#{$$}.#{Time.now.strftime("%Y%m%d.%I%M%S.%s")}.#{Time.now.usec}")
        puts "SCRATCH_DIR #{@scratch_dir}"
      end
  
      def dir name, &block
        @build_dirs.push name
        FileUtils.mkdir( cwd ) unless File.exist?( cwd )
        yield
        @build_dirs.pop
      end
  
      def cwd
        File.join( *@build_dirs )
      end
  
      def writefile content, file
        File.open( File.join( cwd, file ), "w" ) do |f|
          f << content
        end
      end
  
      def style
        " "
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
                b.content :src => "Text/section#{sprintf("%04i",i)}.xhtml"
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
            b.dc :rights, "Creative Commons Non-commercial No Derivatives"
            b.dc :publisher, "Lulu.com"
            b.dc :date, {:"opf:event" => "original-publication"}, "2012"
            b.dc :date, {:"opf:event" => "epub-publication"}, "2012"
            # </metadata>
          end
      
          # <manifest>
          b.manifest do
            #     <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            b.item :id => "ncx", :href => "toc.ncx", :"media-type" => "application/x-dtbncx+xml"
        
            @sections.each_with_index do |section, i|
              b.item :id => "section#{ sprintf("%04i",i) }.xhtml", :href => "Text/section#{ sprintf("%04i",i) }.xhtml", :"media-type" => "application/xhtml+xml"
            end
        
            @images.each do |image|
              b.item :id => image.name, :href => "Images/#{image.name}.#{image.ext}", :"media-type" => image.media_type
            end
            
            @stylesheets.each do |sheet|
              b.item :id => sheet.name, :href => "Styles/#{sheet.name}", :"media-type" => "text/css"
            end
          end
      
          # <spine toc="ncx"> 
          b.spine :toc => "ncx" do
            @sections.each_with_index do |section, i|
              b.itemref :idref => "section#{sprintf("%04i",i)}.xhtml"
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
        FileUtils.rm_r(@scratch_dir) if File.exist?(@scratch_dir)
        dir @scratch_dir do
          writefile mimetype, "mimetype"
  
          dir "META-INF" do
            writefile container, "container.xml"
          end
    
          dir "OEBPS" do
            writefile toc, "toc.ncx"
            writefile content_opf, "content.opf"
        
            dir "Text" do
              @sections.each_with_index do |section, i|
                writefile section.html, "section#{sprintf("%04i",i)}.xhtml"
              end
            end
        
            if @images.length > 0
              dir "Images" do
                for f in @images
                  FileUtils.cp f.file, File.join( cwd, File.basename( f.file ) )
                end
              end
            end
            
            dir "Styles" do
              for sheet in @stylesheets
                writefile sheet.contents, sheet.name
              end
            end
          end
        end
      end
  
      def package epub_file
        epub_file = File.expand_path( epub_file )
        FileUtils.rm( epub_file ) if File.exist?( epub_file )
        # `cd #{SCRATCH_DIR} && zip -Xr #{File.join( "..", epub_file)} #{File.join(SCRATCH_DIR, 'mimetype')} #{File.join(SCRATCH_DIR, 'META-INF')}#{File.join(SCRATCH_DIR, 'OEBPS')}`
        puts "Writing epub directory #{@scratch_dir} to #{epub_file}"
        `cd #{@scratch_dir} && zip -Xr #{epub_file.epf_backhashed_filename} mimetype META-INF OEBPS`
      end
  
      def clean
        # `rm -r #{@scratch_dir}`
      end
    end
  end
end