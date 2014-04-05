# Add htmlizer classes here.  They will be loaded and used in preference over the default htmlizers
# The default htmlizers are given below as examples.
#
#
# # This htmlizer leaves the input file unaltered
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :xhtml
#   html.group      :default
#   html.executable "false"
#   html.cmd        "cat {{f}}"
# end
# 
# # This htmlizer uses the multimarkdown executable.
# # cmd explains to the htmlizer how to execute as a
# # shell command:
# #    {{x}} - name of the executable
# #    {{o}} - then come the options
# #    {{f}} - then the name of the file
# # The output of the executable is captured.  The command you
# # use should output html-tagged text (<h1>...</h1>, <p>...</p>, etc.), 
# # but not a complete html page.
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :markdown
#   html.group      :default                   # the default is :user, so user-defined ones don't have to set it
#   html.executable "multimarkdown"
#   html.cmd        "{{x}} {{o}} {{f}}"
#   # html.opts       ""                         # the default
# end
# 
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :markdown
#   html.group      :default
#   html.executable "pandoc"
#   html.cmd        "{{x}} {{o}} {{f}}"
#   html.opts       "--from=markdown --to=html"
# end
# 
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :textile
#   html.group      :default
#   html.executable "pandoc"
#   html.cmd        "{{x}} {{o}} {{f}}"
#   html.opts       "--from=textile --to=html"
# end
# 
# 
# # Emergency backups
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :markdown
#   html.group      :fallback
#   html.executable "false"
#   html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
# end
# 
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :textile
#   html.group      :fallback
#   html.executable "false"
#   html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
# end
# 
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :txt
#   html.group      :fallback
#   html.executable "false"
#   html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
# end
# 
# # Would be nice to detect and strip out the outer tags
# # leaving only the content.
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :html
#   html.group      :fallback
#   html.executable "false"
#   html.cmd        "cat {{f}}"
# end
# 
# EpubForge::Utils::Htmlizer.define do |html|
#   html.format     :unknown
#   html.group      :fallback
#   html.executable "false"
#   html.cmd        "echo \"<pre>\" && cat {{f}} && echo \"</pre>\""
# end
