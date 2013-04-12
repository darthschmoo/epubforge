# I don't know if mentioning them in the Gemfile automatically requires them.
# Let's find out.
# require 'readline'
# require 'singleton'
# require 'builder'
require 'thor'
require 'debugger'
require 'erb'
require 'singleton'
require 'builder'
require 'pathname'
require 'tmpdir'         # Dir.mktmpdir
require 'net/http'
require 'open-uri'            # needed by Utils::Downloader
require 'yaml'

EpubForge = Module.new
EpubForge::DEBUG = false

def debugger?
  debugger if debugging?
end

def debugging?
  EpubForge::DEBUG
end


require_relative 'core_extensions/array'
# require_relative 'core_extensions/file'
require_relative 'core_extensions/kernel'
require_relative 'core_extensions/nil_class'
require_relative 'core_extensions/object'
require_relative 'core_extensions/string'


require_relative 'utils/directory_builder'
require_relative 'utils/downloader'
require_relative 'utils/file_orderer'
require_relative 'utils/file_path'  # 
require_relative 'utils/misc'
require_relative 'utils/root_path'
require_relative 'utils/class_loader'
require_relative 'utils/action_loader'
require_relative 'utils/htmlizer'
require_relative 'utils/default_htmlizers'
require_relative 'utils/template_evaluator'

EpubForge.set_root_path( __FILE__.epf_filepath.dirname.up )

module EpubForge
  TEMPLATE_DIR = EpubForge.root.join( "templates" )
end

require_relative 'action/abstract_action'
require_relative 'action/file_transformer'
require_relative 'action/run_description'
require_relative 'action/thor_action'
require_relative 'action/runner'
require_relative 'action/cli_command'
require_relative 'action/cli_sequence'
require_relative 'custom_helpers'
require_relative 'epub/builder'
require_relative 'epub/packager'
require_relative 'epub/assets/asset'
require_relative 'epub/assets/page'
require_relative 'epub/assets/html'
require_relative 'epub/assets/markdown'
require_relative 'epub/assets/textile'
require_relative 'epub/assets/image'
require_relative 'epub/assets/stylesheet'
require_relative 'project/project'

puts "Requirements loaded" if debugging?

puts "Done with tests inside epubforge.rb" if debugging?
