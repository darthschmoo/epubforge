# I don't know if mentioning them in the Gemfile automatically requires them.
# Let's find out.
# require 'readline'
# require 'singleton'
# require 'builder'
require 'singleton'
require 'builder'
require 'debugger'
require 'pathname'
require 'tmpdir'         # Dir.mktmpdir

EpubForge = Module.new
EpubForge::DEBUG = false

def debugger?
  debugger if debugging?
end

def debugging?
  EpubForge::DEBUG
end

# Allow me to use all my fave decorative 
# methods without polluting everyone else's.
require_relative 'core_extensions/array'
require_relative 'core_extensions/file'
require_relative 'core_extensions/kernel'
require_relative 'core_extensions/object'
require_relative 'core_extensions/string'


require_relative 'utils/file_path'  # 
require_relative 'utils/root_path'

EpubForge.set_root_path( __FILE__.epf_filepath.dirname.up )

require_relative 'action/abstract_action'
require_relative 'action/file_transformer'
require_relative 'action/run_description'
require_relative 'action/runner'
require_relative 'custom_helpers'
require_relative 'epub/builder'
require_relative 'epub/image'
require_relative 'epub/stylesheet'
require_relative 'page/abstract_page'
require_relative 'page/html'
require_relative 'page/markdown'
require_relative 'project/project'

puts "Requirements loaded" if debugging?

puts "Done with tests inside epubforge.rb" if debugging?
