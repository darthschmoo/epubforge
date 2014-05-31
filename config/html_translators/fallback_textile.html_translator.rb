EpubForge::Utils::HtmlTranslator.new do
  name       :fallback_textile
  format     :textile
  group      :fallback
  executable "false"
  cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end
