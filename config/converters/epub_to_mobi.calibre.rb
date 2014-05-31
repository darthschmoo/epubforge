EpubForge::Utils::Converter.new do
  label         :epub_to_mobi_calibre
  input_format  :epub
  output_format :mobi
  executable    "ebook-convert"
  
  help          "To use #{label}, download the latest version of Calibre at http://calibre-ebook.com/download, then make sure 'ebook-convert' is in your command line's search path."
end