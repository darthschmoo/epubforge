require 'helper'
require 'thor'

class TestEpubforge < Test::Unit::TestCase  # 
  context "Testing a few basic commands" do
    should "print successfully" do
      printout = EpubForge.collect_stdout do
        EpubForge::Action::Runner.new.exec    # empty args, should append --help
      end

      assert_match /\( wc \| count \)/, printout
      assert_match /epubforge \[action\] \[folder\]/, printout
    end
    
    should "initialize a new project" do
      create_project do
        assert @project_dir.join( EpubForge::Project::SETTINGS_FOLDER, EpubForge::Project::CONFIG_FILE_NAME ).file?
        assert @project_dir.join( "settings", "actions" ).directory?
        assert @project_dir.join( "notes" ).directory?
        assert @project_dir.join( "book", "title_page.markdown" ).file?
        assert @project_dir.join( "book", "images", "cover.png" ).file?
        assert_equal 1, @project_dir.join( "book", "chapter-0001.markdown" ).grep( /^Chapter/ ).length
      end
    end
    
    context "testing a fresh project" do
      should "successfully count ALL THE WORDS!" do
        create_project do
          EpubForge.collect_stdout do
            report = EpubForge::Action::Runner.new.exec( "wc", @project_dir ).execution_returned
            assert_kind_of Hash, report
            assert_equal 119, report["Book"]
            assert_equal 126, report["Today"]
            assert @project_dir.join( EpubForge::Project::SETTINGS_FOLDER, EpubForge::Action::WordCount::WORD_COUNT_FILE ).exist?
          end
        end  
      end
    
      should "fail to count words when no project is given and cwd is not a project" do
        create_project do
          printout = EpubForge.collect_stdout do
            run_description = EpubForge::Action::Runner.new.exec( "wc" )
            assert_equal nil, run_description.execution_returned
            assert_equal false, run_description.success?
          end
          
          assert_match /Error\(s\) trying to complete the requested action/, printout
          assert_match /Current directory is not an epubforge project/, printout
        end  
      end
      
      should "create an .epub file" do
        create_project do
          printout = EpubForge.collect_stdout do
            EpubForge::Action::Runner.new.exec( "forge", @project_dir )
          end
          
          assert @ebook_file.file?
          assert_match /Done building epub/, printout
          
          Dir.mktmpdir do |unzip_dir|
            unzip_dir = unzip_dir.fwf_filepath
            `unzip #{@ebook_file} -d #{unzip_dir}`
            
            unzip_dir.join("META-INF") do |d|
              assert d.directory?
              container = d.join( "container.xml" )
              assert container.file?
              
            end
            
            unzip_dir.join("OEBPS") do |d|
              d.join("Images") do |d|
                assert d.directory?
                assert d.join("cover.png").file?
              end
              
              d.join("Text") do |d|
                d.join( "afterword.xhtml" ) do |section|
                  assert section.file?, "file should exist: chapter-0002.xhtml"
                  section_text = section.read
                  assert_match /DOCTYPE/, section_text
                  assert_match /<title>#{@book_title}<\/title>/, section_text
                  assert_match /Now go find something else to do/, section_text
                end
              end
              
              d.join("Styles") do |d|
                assert d.directory?
              end
              
              d.join( "content.opf" ) do |content|
                content_text = content.read
                assert_match /<dc:title>#{@book_title}<\/dc:title>/, content_text
                assert_match /Text\/chapter-0003/, content_text
              end
              
              d.join( "toc.ncx" ) do |toc|
                assert_equal 1, toc.grep( /DOCTYPE/ ).length
                assert_equal 4, toc.grep( /meta name=/ ).length
                
                section_count = EpubForge.root( "templates", "default", "book" ).glob( :ext => ["template", "sequence"] ).length + @chapter_count - 1
                assert_equal section_count, toc.grep( /xhtml/ ).length
                assert_equal 1, toc.grep( /#{@book_title}/ ).length
                
                assert_equal section_count, toc.grep( /<content src=/ ).length
              end
            end
          end
        end
      end
      
      should "create an .epub of the notes directory" do
        create_project do
          EpubForge::Action::Runner.new.exec( "forge_notes", @project_dir )
          
          assert @notes_file.file?
          assert ! @notes_file.empty?
        end
      end
    end
        
    protected
    def create_project( &block )
      EpubForge::Utils::DirectoryBuilder.tmpdir do |d|
        @project_dir = d.current_path.join("project")
        @printout = EpubForge.collect_stdout do
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
