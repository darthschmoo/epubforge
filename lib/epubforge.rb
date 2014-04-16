%w( thor
    optparse
    nokogiri
    xdg
    debugger
    erb
    singleton
    builder
    pathname
    tmpdir
    rbconfig
    fun_with_gems
    fun_with_templates
    fun_with_configurations
    fun_with_string_colors
    fun_with_patterns ).map{|requirement| require requirement}
    
    
FunWith::StringColors.activate
String.colorize( true )


# EpubForge.root responds with the gem directory
# FunWith::Files::RootPath.rootify( EpubForge, __FILE__.fwf_filepath.dirname.up )
# FunWith::VersionStrings.versionize( EpubForge )
# 
# EpubForge.root("lib","epubforge").requir

module EpubForge
  USER_SETTINGS = XDG['CONFIG_HOME'].fwf_filepath( "epubforge" )
  DEBUG = false
end

FunWith::Gems.make_gem_fun( "EpubForge" )




# EpubForge.root("lib", "epub", "assets", "page").requir
# require_relative 'core_extensions/array'
# require_relative 'core_extensions/kernel'
# require_relative 'core_extensions/nil_class'
# require_relative 'core_extensions/object'
# require_relative 'core_extensions/string'

# require_relative 'utils/directory_builder'
# require_relative 'utils/downloader'
# require_relative 'utils/file_orderer'
# require_relative 'utils/misc'
# require_relative 'utils/class_loader'
# require_relative 'utils/action_loader'
# require_relative 'utils/template_evaluator'



module EpubForge
  ACTIONS_DIR  = EpubForge.root.join( "config", "actions" )
  TEMPLATES_DIR  = EpubForge.root.join( "templates" )
  USER_GLOBALS_FILE = USER_SETTINGS.join( "globals.rb" )
  USER_ACTIONS_DIR  = USER_SETTINGS.join( "actions" )
  
  puts "Warning:  Cannot create user settings folder." unless USER_ACTIONS_DIR.touch_dir
  puts "Warning:  Cannot create globals file."         unless USER_GLOBALS_FILE.touch
end

EpubForge.install_fwc_config_from_file( EpubForge::USER_GLOBALS_FILE )

# EpubForge.config.activation_key = rand(20**32).to_s(16).gsub(/(.{5})/, '\1-')[0..-2]

# require_relative 'utils/html_translator'
# require_relative 'utils/html_translator_queue'
# require_relative 'utils/htmlizer'
# 
# require_relative 'action/file_transformer'
# require_relative 'action/run_description'
# require_relative 'action/thor_action'
# require_relative 'action/actions_lookup'
# require_relative 'action/runner'
# require_relative 'action/cli_command'
# require_relative 'action/cli_sequence'
# require_relative 'custom_helpers'
# require_relative 'epub/builder'
# require_relative 'epub/packager'
# require_relative 'epub/assets/asset'
# require_relative 'epub/assets/page'
# require_relative 'epub/assets/html'
# require_relative 'epub/assets/markdown'
# require_relative 'epub/assets/textile'
# require_relative 'epub/assets/image'
# require_relative 'epub/assets/stylesheet'
# require_relative 'epub/assets/xhtml'
# require_relative 'project/project'

EpubForge.extend( EpubForge::CustomHelpers )

