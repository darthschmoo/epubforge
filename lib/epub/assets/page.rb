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
          @title = @original_file.basename.to_s.split(".")[0..-2].map(&:capitalize).join(" : ")
        end
        
        def link
          TEXT_DIR.join( "#{@section_id}.#{@dest_extension}" )
        end
        
        def media_type
          MEDIA_TYPES[@dest_extension]
        end
        
        def cover( val = nil )
          unless val.nil?
            @cover = val
          end
          @cover
        end
        
        def cover_asset( val = nil )
          unless val.nil?
            @cover = val
          end
          @cover
        end
      end
    end
  end
end