module EpubForge
  module Epub
    MEDIA_TYPES = { "gif" => "image/gif", "jpg" => "image/jpeg", "png" => "image/png",
                    "css" => "text/css", "js" => "application/javascript", "pdf" => "application/pdf",
                    "txt" => "text/plain" 
                  }
    IMAGES_DIR = "".epf_filepath.join( "/", "OEBPS", "Images" )
    STYLE_DIR  = "".epf_filepath.join( "/", "OEBPS", "Styles" )
    HTML_DIR   = "".epf_filepath.join( "/", "OEBPS", "Text" )

    module Assets
      class Asset
        def media_type
          MEDIA_TYPES[@ext]
        end
      end
    end
  end
end