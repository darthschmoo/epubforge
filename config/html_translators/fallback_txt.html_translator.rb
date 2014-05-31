
EpubForge::Utils::HtmlTranslator.new do
  name       :fallback_txt
  format     :txt
  group      :fallback
  executable "false"
  cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end
