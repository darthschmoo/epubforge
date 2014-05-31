# # Define only one translator per file.
# #
# # This htmlizer leaves the input file unaltered
# # Uncomment the line below, and the matching 'end' statement at the end
# EpubForge::Utils::HtmlTranslator.new do
# #  format() describes the file extension that this translator will accept.  It's a symbol, so do
# # :txt rather than .txt, for example.
#   format     :xhtml
# # group() describes which group it belongs in, and therefore the priority of this translator.  
# # From most to least important, valid groups are :preferred, :user, :default, and :fallback
#   group      :default
#
# # executable(): The executable that will be substituted into the {{x}} portion of the command
# # that will be executed.  If you don't give it the name of
# # a program in your path, or an absolute filepath, the translator will respond to translation 
# # requests with "not installed", and a lower-priority translator will be sought.
#   executable "false"
#
#  # cmd() What to run.  
#  #   {{f}} will be replaced with the filename
#  #   {{o}} will be replaced with options
#  #   {{x}} will be replaced with the name of the executable
#   cmd        "cat {{f}}"
# 
# # Putting it all together:  This translator just says "if you come across an XHTML file, just 
# # include it unaltered."
# #
# # Uncomment the 'end' line, cuz Ruby.
# end
