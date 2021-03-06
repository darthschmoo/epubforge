module EpubForge
  module Builder
    class Epub < Builder
      def package( epub_filename )
        epub_filename = epub_filename.fwf_filepath.expand
        FileUtils.rm( epub_filename ) if epub_filename.exist?
        `cd #{@scratch_dir} && zip -Xr #{epub_filename.to_s.epf_backhashed_filename} mimetype META-INF OEBPS`
      end
      
      def clean
        # do nothing?  Remove scratch dir?
      end
      
      # zips up contents
      def build
        FunWith::Files::DirectoryBuilder.create( @scratch_dir ) do |build|
          
          build.file( "mimetype", mimetype )
          
          build.dir( "META-INF" ) do
            build.file("container.xml", container)
          end
          
          build.dir( "OEBPS" ) do
            build.file( "toc.ncx", toc )
            build.file( "content.opf", content_opf )
            
            build.dir( "Text" ) do
              @sections.each do |section|
                content = section.html
                content = wrap_page( content, section.section_id ) unless section.source_format == :xhtml
                
                build.file( section.dest_filename, content )
              end
            end
          
            unless @images.fwf_blank?
              build.dir "Images" do
                for img in @images
                  build.copy( img.filename )
                end
              end
            end
          
            unless @stylesheets.fwf_blank?
              build.dir "Styles" do
                for sheet in @stylesheets
                  build.file( sheet.name, sheet.contents )
                end
              end
            end
            
            unless @fonts.fwf_blank?
              build.dir "Fonts" do
                for font in @fonts
                  build.copy( font.filename )
                end
              end
            end
          end
        end
      end
   
      protected
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
            b.meta :name => "dtb:uid", :content => @metadata["uuid"]
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
            b.dc :identifier, {:id => "BookID", "opf:scheme" => "UUID"}, "#{@metadata["uuid"]}"  #TODO Unique id generator
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
    end
  end
end