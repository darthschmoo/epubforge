require 'rubygems'
require 'bundler'
require 'shoulda'
require 'stringio'
require 'thor'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'epubforge'

module EpubForge
  class TestCase < Test::Unit::TestCase
    protected
    def create_project( verbose = false, &block )
      EpubForge::Utils::DirectoryBuilder.tmpdir do |d|
        pipe_output_to = (verbose ? $stdout : StringIO.new)
        @project_dir = d.current_path.join("project")
        
        @printout = EpubForge.collect_stdout( pipe_output_to ) do   # collect_stdout(STDOUT) to see what's being outputted.
          EpubForge::Action::Runner.new.exec( "init", @project_dir, fill_in_project_options )
        end

        assert @project_dir.directory?, "Project directory doesn't exist.  Cannot proceed."

        @book_title = fill_in_project_options[:answers][:title]
        @chapter_count = fill_in_project_options[:answers][:chapter_count].to_i
        @ebook_file = @project_dir.join( @book_title.epf_underscorize + ".epub" )
        @notes_file = @project_dir.join( @book_title.epf_underscorize + ".notes.epub" )

        yield
      end
    end

    def fill_in_project_options( opts = {} )
      template_options = { 
        :answers => {
          :chapter_count => 3,
          :title => "The Courtesan of Fate",
          :author => "Wilberforce Poncer",
          :license => "You Owe Me All the Money Limited License, v. 2.1",
          :use_git => true,
          :git => {
            :repo_id => "abcdef0123456789",
            :backup_type => "Back up to a remote host.",
            :host => "myhost.somewhere.com",
            :user => "andersbr",
            :repo => "/home/andersbr/git"
          }
        }
      }
    
      template_options[:answers].merge(opts)
    
      template_options
    end
  end
end
