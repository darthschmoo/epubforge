# Would be nice to detect and strip out the outer tags
# leaving only the content.
EpubForge::Utils::HtmlTranslator.new do
  name       :fallback_html
  format     :html
  group      :fallback
  executable "false"
  cmd        "cat {{f}}"
end
