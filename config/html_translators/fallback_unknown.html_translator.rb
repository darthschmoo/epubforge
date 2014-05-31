EpubForge::Utils::HtmlTranslator.new do
  name       :fallback_unknown
  format     :unknown
  group      :fallback
  executable "false"
  cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end
