module EpubForge
  module Epub
    module Assets
      class Page < Asset
        attr_reader :html, :original_file, :title, :project, :media_type, :dest_extension, :dest_filename
        attr_reader :section_id

        def initialize file, metadata, project
          raise "NIL" if project.nil?
          
          @original_file = file.fwf_filepath
        
          @metadata = metadata
          @project  = project
          @dest_extension = "xhtml"
          @section_id = @original_file.basename_no_ext
          @dest_filename = "#{@section_id}.#{@dest_extension}"

          get_html
          get_title
          
          @content = ""
          @cover = false
          puts "Initialized #{file} with title [#{@title}]"
        end
        
        def get_html
          @html = Utils::Htmlizer.instance.translate( @original_file )
        end
        
        def get_title
          html_doc = Nokogiri::HTML( @html )
          h1 = html_doc.xpath("//h1").first
          
          if h1.nil?
            @title = @original_file.basename.to_s.split(".")[0..-2].map(&:capitalize).join(" : ")
          else
            title = h1.content
            @title = title.gsub(/\s*\/+\s*/, "").epf_titlecap_words
          end
        end
        
        def link
          TEXT_DIR.join( "#{@section_id}.#{@dest_extension}" )
        end
        
        def item_id
          cover? ? "cover" : self.link.basename
        end
        
        def media_type
          MEDIA_TYPES[@dest_extension]
        end
        
        def cover?
          @section_id == "cover"
        end
      end
    end
  end
end