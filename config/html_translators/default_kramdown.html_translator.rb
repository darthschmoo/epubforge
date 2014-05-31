EpubForge::Utils::HtmlTranslator.new do
  name       :epubforge_markdown
  format     :markdown
  group      :default                   # the default is :user, so user-defined ones don't have to set it

  custom_proc do |filepath, *args|
    Kramdown::Document.new( filepath.read ).to_html
  end
end
