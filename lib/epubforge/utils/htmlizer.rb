# module EpubForge
#   module Utils
#     
#     # Htmlizer coordinates the discovery, selection, and running of HtmlTranslators.
#     # It can be handed basically any supported filetype (markdown, textile, txt), and 
#     # hand back an HTML translation of the file.
#     class Htmlizer
#       include Singleton
# 
#       def setup_once
#         return false if @already_set_up 
#         @already_set_up = true
#         @exec_location = {}
#         
#         # @translator_queue = HtmlTranslatorQueue.new
#         
#         @already_set_up
#       end
#             
# 
#       # Commenting out for the moment.  Philosophically, maybe it shouldn't provide access to individual translators.
#       # def translators_named( name )
#       #   @translator_queue[:named][name]
#       # end
# 
#       # 
#       # def self.define( &block )
#       #   htmlizer = HtmlTranslator.new
#       #   yield htmlizer
#       #   HtmlTranslator.categorize( htmlizer )
#       # end
#       # 
#       # def categorize( htmlizer )
#       #   HtmlTranslator.categorize( htmlizer )
#       # end
#       # 
#       # def add_htmlizers( htmlizers_file )
#       #   if htmlizers_file.exist?
#       #     begin
#       #       require htmlizers_file.to_s
#       #     rescue Exception => e
#       #       puts e.message
#       #       puts e.backtrace.map{|line| "\t#{line}" }
#       #       puts "Failed to load htmlizers from project file #{htmlizers_file} Soldiering onward."
#       #     end
#       #   end
#       # end
# 
#       
#       # available options
#       # :htmlizer => the sym for the requested htmlizer.  
#       # :opts     => a string representing options to execute cmd with
# 
# 
# 
#     end
#     
#     Htmlizer.instance.setup_once
#   end
# end
# 
