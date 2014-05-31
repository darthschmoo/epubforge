# # Uncomment if you'd rather use the pandoc executable
#
# EpubForge::Utils::HtmlTranslator.new do
#   name       :epubforge_pandoc_markdown
#   format     :markdown
#   group      :default
#   executable "pandoc"
#   cmd        "{{x}} {{o}} {{f}}"
#   opts       "--from=markdown --to=html"
# end
