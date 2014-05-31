EpubForge::Utils::HtmlTranslator.new do
  name       :epubforge_pandoc_textile
  format     :textile
  group      :default
  executable "pandoc"
  cmd        "{{x}} {{o}} {{f}}"
  opts       "--from=textile --to=html"
end
