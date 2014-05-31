EpubForge::Utils::HtmlTranslator.new do
  name       :epubforge_xhtml
  format     :xhtml
  group      :default
  executable "false"
  cmd        "cat {{f}}"
end