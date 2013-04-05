require 'helper'

class TestEpubforge < Test::Unit::TestCase  # 
  context "Testing a few basic commands" do
    should "print successfully" do
      printout = collect_stdout do
        EpubForge::Action::Runner.instance.execute_args    # empty args, should append --help
      end
      
      assert_match /\( wc \| count \)/, printout
      assert_match /epubforge \[action\] \[folder\]/, printout
    end
    
    should "initialize a new project" do
      create_project do
        assert @project_dir.join( EpubForge::RECIPE_FILE_NAME ).file?
        assert @project_dir.join( "actions" ).directory?
        assert @project_dir.join( "notes" ).directory?
        assert @project_dir.join( "book", "title_page.markdown" ).file?
        assert @project_dir.join( "book", "images", "cover.png" ).file?
        assert_equal 4, @project_dir.join( "book", "chapter.01.markdown" ).grep( /George/ ).length
      end
    end
    
    context "testing a fresh project" do
      should "successfully count ALL THE WORDS!" do
        create_project do
          collect_stdout do
            report = EpubForge::Action::Runner.instance.execute_args( "wc", @project_dir )
            assert_kind_of Hash, report
            assert_equal 100, report["Book"]
            assert_equal 107, report["Today"]
            assert @project_dir.join(EpubForge::Action::WordCount::WORD_COUNT_FILE).exist?
          end
        end  
      end

      should "fail to count words when no project is given and cwd is not a project" do
        create_project do
          printout = collect_stdout do
            assert !EpubForge::Action::Runner.instance.execute_args( "wc" )
          end
          
          assert_match /No project directory was given/, printout
          assert_match /current working directory is not an epubforge project/, printout
        end  
      end
      
      should "create an .epub file" do
        create_project do
          printout = collect_stdout do
            EpubForge::Action::Runner.instance.execute_args( "forge", @project_dir )
          end
          assert @project_dir.join( "my_ebook.epub" ).file?
          assert_match /Done building epub/, printout
          
          Dir.mktmpdir do |unzip_dir|
            unzip_dir = unzip_dir.epf_filepath
            `unzip #{@project_dir.join("my_ebook.epub")} -d #{unzip_dir}`
            
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
                d.join( "section0002.xhtml" ) do |section|
                  assert section.file?
                  section_text = section.read
                  assert_match /DOCTYPE/, section_text
                  assert_match /Then George died/, section_text
                end
              end
              
              d.join("Styles") do |d|
                assert d.directory?
              end
              
              d.join( "content.opf" ) do |content|
                content_text = content.read
                assert_match /<dc:title>My Nifty Project<\/dc:title>/, content_text
                assert_match /Text\/section0003/, content_text
              end
              
              d.join( "toc.ncx" ) do |toc|
                assert_equal 1, toc.grep( /DOCTYPE/ ).length
                assert_equal 4, toc.grep( /meta name=/ ).length
                assert_equal 4, toc.grep( /Markdown/ ).length
                assert_equal 1, toc.grep( /My Nifty Project/ ).length
              end
            end
          end
        end
      end
      
      should "create an .epub of the notes directory" do
        create_project do
          EpubForge::Action::Runner.instance.execute_args( "forge_notes", @project_dir )
          
          assert @project_dir.join( "my_ebook.notes.epub" ).file?
          assert ! @project_dir.join( "my_ebook.notes.epub" ).empty?
        end
        puts "----------------"
      end
    end
    
    
    
    def create_project( &block )
      EpubForge::Utils::DirectoryBuilder.tmpdir do |d|
        @project_dir = d.current_path.join("project")
        @printout = collect_stdout do
          EpubForge::Action::Runner.instance.execute_args( "init", @project_dir )
        end
        yield
      end
    end
  end
end
