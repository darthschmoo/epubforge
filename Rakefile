# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "epubforge"
  gem.homepage = "http://github.com/darth_schmoo/epubforge"
  gem.license = "MIT"
  gem.summary = %Q{Write your book in markdown, then do all sorts of increasingly nifty things with it.}
  gem.description = File.read( File.join( ".", "README.rdoc" ) )
  gem.email = "keeputahweird@gmail.com"
  gem.authors = ["Bryce Anderson"]
  # dependencies defined in Gemfile
  
  
  gem.files = Dir.glob( File.join( ".", "lib", "**", "*.rb" ) ) + 
              Dir.glob( File.join( ".", "templates", "**", "*.*" ) ) +
              Dir.glob( File.join( ".", "test", "**", "*.*" ) ) +
              Dir.glob( File.join( ".", "actions", "**", "*.rb" ) ) +
              Dir.glob( File.join( ".", "actions", "**", "*.rb" ) ) +
              [ "Gemfile", 
                "Rakefile", 
                "LICENSE.txt", 
                "README.rdoc",
                "VERSION",
                File.join( ".", "bin", "epubforge" ) 
              ]
               
  gem.default_executable = File.join( ".", "bin", "epubforge" )
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# require 'rcov/rcovtask'
# Rcov::RcovTask.new do |test|
#   test.libs << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
#   test.rcov_opts << '--exclude "gems/*"'
# end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "epubforge #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
