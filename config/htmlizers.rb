EpubForge::Utils::Htmlizer.define do |html|
  html.format     :xhtml
  html.group      :default
  html.executable "false"
  html.cmd        "cat {{f}}"
end


EpubForge::Utils::Htmlizer.define do |html|
  html.format     :markdown
  html.group      :default                   # the default is :user, so user-defined ones don't have to set it
  html.executable "multimarkdown"
  html.cmd        "{{x}} {{o}} {{f}}"
  # html.opts       ""                         # the default
end

EpubForge::Utils::Htmlizer.define do |html|
  html.format     :markdown
  html.group      :default
  html.executable "pandoc"
  html.cmd        "{{x}} {{o}} {{f}}"
  html.opts       "--from=markdown --to=html"
end

EpubForge::Utils::Htmlizer.define do |html|
  html.format     :textile
  html.group      :default
  html.executable "pandoc"
  html.cmd        "{{x}} {{o}} {{f}}"
  html.opts       "--from=textile --to=html"
end


# Emergency backups
EpubForge::Utils::Htmlizer.define do |html|
  html.format     :markdown
  html.group      :fallback
  html.executable "false"
  html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end

EpubForge::Utils::Htmlizer.define do |html|
  html.format     :textile
  html.group      :fallback
  html.executable "false"
  html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end

EpubForge::Utils::Htmlizer.define do |html|
  html.format     :txt
  html.group      :fallback
  html.executable "false"
  html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end

# Would be nice to detect and strip out the outer tags
# leaving only the content.
EpubForge::Utils::Htmlizer.define do |html|
  html.format     :html
  html.group      :fallback
  html.executable "false"
  html.cmd        "cat {{f}}"
end

EpubForge::Utils::Htmlizer.define do |html|
  html.format     :unknown
  html.group      :fallback
  html.executable "false"
  html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
end
