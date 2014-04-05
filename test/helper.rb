require 'bundler'
require 'shoulda'
require 'stringio'
require 'fun_with_testing'

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
    include EpubForge::Utils
    include FunWith::Testing::Assertions::Basics
    include FunWith::Testing::Assertions::FunWithFiles
    
    protected
    def self._context(*args, &block)
      puts "IGNORING TEST SET #{args.inspect}".paint(:bold, :bg_red)
    end

    def self._should(*args, &block)
      puts "IGNORING TEST #{args.inspect}".paint(:red, :bold, :reverse)
    end

    
    def create_project( verbose = false, &block )
      verbose = true
      FunWith::Files::DirectoryBuilder.tmpdir do |d|
        pipe_output_to = (verbose ? $stdout : StringIO.new)
        @project_dir = d.current_path.join("project")
        
        @printout = EpubForge.collect_stdout( pipe_output_to ) do   # collect_stdout(STDOUT) to see what's being outputted.
          @returned = EpubForge::Action::Runner.new.exec( "init", @project_dir, fill_in_project_options )
        end
        
        assert_directory( @project_dir, "Project directory doesn't exist.  Cannot proceed." )

        @default_opts = fill_in_project_options[:answers]
        @book_title = @default_opts[:book][:title]

        @chapter_count = @default_opts[:chapter].last
        @ebook_file = @project_dir.join( @book_title.epf_underscorize + ".epub" )
        @notes_file = @project_dir.join( @book_title.epf_underscorize + ".notes.epub" )

        yield
      end
    end

    def fill_in_project_options( opts = {} )
      template_options = YAML.load( EpubForge.root("test", "answers01.yml").read )
      template_options[:answers].merge(opts)
    
      template_options
    end
    
    def tempdir( &block )
      FunWith::Files::FilePath.tmpdir do |d|
        @tmpdir = d
        yield
      end
    end
    
    def runner_exec( *args )
      if @runner_exec_quiet
        @runner_exec_printout = EpubForge.collect_stdout do
          @run_description = EpubForge::Action::Runner.new.exec( *args )
        end
      else
        @run_description = EpubForge::Action::Runner.new.exec( *args )
      end
      
      if @run_description.errors? # , "running forge caused errors (#{run_desc.errors.length})"
        error = @run_description.errors.first
        case @runner_exec_errors_action
        when :raise
          raise error
        when :print
          puts "Runner.new.exec() args = #{args.inspect}"
          puts error.message
          puts "\t" + error.backtrace.map{|line| "\t#{line}"}.join("\n")
          puts "\n"
        when :ignore
          # do nothing
        end
      end
    end
  end
end
