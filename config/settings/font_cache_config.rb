remote_repo_url         "https://github.com/w0ng/googlefontdirectory"
local_repo              EpubForge::USER_SETTINGS.join( "fonts", "googlefontdirectory" )
download_root           "https://github.com/w0ng/googlefontdirectory/blob/master/fonts/"
# download_root           "http://raw.githubusercontent.com/w0ng/googlefontdirectory/master/fonts/" 
cache_dir               EpubForge::USER_SETTINGS.join( "fonts", "cache" )
font_descriptions_file  EpubForge::GLOBAL_SETTINGS.join( "font_data.google.yaml" )
font_face_css_template  EpubForge::TEMPLATES_DIR.join( "project", "book", "stylesheets", "font_face.%font.filebase%.%font.weight%.%font.style%.css.template" )
