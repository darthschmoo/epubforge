require "thor"
require "optparse"
require "nokogiri"
require "xdg"
require "debugger"
require "erb"
require "singleton"
require "builder"  # XML Builder, not our builder
require "pathname"
require "tmpdir"
require "rbconfig"
require "kramdown"
require "fun_with_gems"
require "fun_with_templates"
require "fun_with_configurations"
require "fun_with_string_colors"
require "fun_with_patterns"
require "json"

    
FunWith::StringColors.activate
String.colorize( true )
FunWith::Patterns::GetAndSet.activate

FunWith::Gems.make_gem_fun( "EpubForge" )

EpubForge::CoreExtensions.install_extensions

module EpubForge
  GLOBAL_SETTINGS = EpubForge.root( "config", "settings" )
  USER_SETTINGS = XDG['CONFIG_HOME'].fwf_filepath( "epubforge" )
  DEBUG = false

  ACTIONS_DIR  = EpubForge.root.join( "config", "actions" )
  USER_ACTIONS_DIR  = USER_SETTINGS.join( "actions" )
  CONVERTERS_DIR = EpubForge.root.join( "config", "converters" )
  USER_CONVERTERS_DIR = USER_SETTINGS.join( "converters" )
  
  HTML_TRANSLATORS_DIR = EpubForge.root.join( "config", "html_translators" )
  USER_HTML_TRANSLATORS_DIR = USER_SETTINGS.join( "html_translators" )
  
  TEMPLATES_DIR  = EpubForge.root.join( "templates" )
  USER_GLOBALS_FILE = USER_SETTINGS.join( "globals.rb" )
  
  puts "Warning:  Cannot create user settings folder." unless USER_ACTIONS_DIR.touch_dir
  puts "Warning:  Cannot create globals file."         unless USER_GLOBALS_FILE.touch
end

EpubForge.install_fwc_config_from_file( EpubForge::USER_GLOBALS_FILE )

EpubForge.extend( EpubForge::CustomHelpers )

EpubForge::Action::Action2.loader_pattern_load_from_dir( EpubForge::ACTIONS_DIR, EpubForge::USER_ACTIONS_DIR )
EpubForge::Utils::Converter.loader_pattern_load_from_dir( EpubForge::CONVERTERS_DIR, EpubForge::USER_CONVERTERS_DIR )
EpubForge::Utils::HtmlTranslator.loader_pattern_load_from_dir( EpubForge::HTML_TRANSLATORS_DIR, EpubForge::USER_HTML_TRANSLATORS_DIR )


EpubForge::Fonts.install_fwc_config_from_file( EpubForge::GLOBAL_SETTINGS.join( "font_cache_config.rb" ) )
