# Emergency backups
EpubForge::Utils::HtmlTranslator.new do
  name       :fallback_markdown
  format     :markdown
  group      :fallback
  executable "false"
  cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end
