require 'helper'

class TestEpubforge < EpubForge::TestCase  # 
  context "Testing a few basic commands" do
    # TODO: Figure out wtf to do for a help system
    # should "print successfully" do
    #   printout = EpubForge.collect_stdout do
    #     EpubForge::Action::Runner.new.exec    # empty args, should append --help
    #   end
    # 
    #   assert_match /\( wc \| count \)/, printout
    #   assert_match /epubforge \[action\] \[folder\]/, printout
    # end
    
    should "initialize a new project" do
      create_project do
        assert_file @project_dir.join( EpubForge::Project::SETTINGS_FOLDER, EpubForge::Project::CONFIG_FILE_NAME )
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
            assert_equal 122, report["Book"]
            assert_equal 157, report["Today"]
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
          puts printout.paint(:red, :invert, :white)
          assert_match /Could not find a project directory/, printout
        end  
      end
      
      should "create an .epub file" do
        create_project do
          # printout = EpubForge.collect_stdout() do    # .collect_stdout(STDOUT) to see what's going on
          #             EpubForge::Action::Runner.new.exec( "forge", @project_dir )
          #           end
          @runner_exec_errors_action = :raise
          
          runner_exec( "epub", @project_dir )
          raise @run_description.errors.first if @run_description.errors? # , "running forge caused errors (#{run_desc.errors.length})"
          
          assert_file @ebook_file, "Ebook was not created"
          assert_match /Done building epub/, @runner_exec_printout if @runner_exec_printout
          
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
                
                section_count = EpubForge.root( "templates", "project", "book" ).glob( :ext => ["markdown", "template"] ).length + @chapter_count - 1
                assert_equal section_count, toc.grep( /xhtml/ ).length
                assert_equal 2, toc.grep( /#{@book_title}/ ).length
                
                assert_equal section_count, toc.grep( /<content src=/ ).length
              end
            end
          end
        end
      end

      
      should "create an .epub of the notes directory" do
        create_project do
          runner_exec( "epub:notes", @project_dir )
          assert @notes_file.file?
          assert ! @notes_file.empty?
        end
      end
      
      should "print friggin' something when no args" do
        runner_exec()
      end
      
      should "install a font" do
        create_project do
          runner_exec( "font:install", "Ubuntu", @project_dir_as_arg )
          
          @project_dir.join( "book" ) do |bookdir|
            bookdir.join( "fonts" ) do |fontdir|
              assert_equal 8, fontdir.glob(:ext => :ttf).length
              fontdir.join( "Ubuntu-Regular.ttf" ) do |fontfile|
                assert_fwf_filepath fontfile
                assert_file_not_empty fontfile
              end
            end
            
            bookdir.join( "stylesheets" ) do |styledir|
              assert_directory styledir
              styledir.join( "font_face.ubuntu.css" ) do |facefile|
                assert_file_not_empty facefile
                assert_file_contents facefile, /@font-face \{/, 8
              end
            end
            
            # Knit the book together and unzip into a temporary directory.  Examine results.
            runner_exec( "epub", @project_dir_as_arg )
            runner_exec( "epub:unzip", @project_dir_as_arg )
            
            tmpdir = @project_dir.glob("tmp.*").first
            assert_directory tmpdir
            
            tmpdir.join("OEBPS", "Fonts") do |fontdir|
              assert 8, fontdir.glob(:ext => :ttf).length
              for fontfile in fontdir.glob(:ext => :ttf)
                assert_file_not_empty fontfile
              end
            end
          end
        end
      end
      
      should "implicitly create epub when asked to unzip" do
        create_project do
          runner_exec( "epub:unzip", @project_dir_as_arg )
          tmpdir = @project_dir.glob("tmp.*").first
          
          assert_directory( tmpdir.join( "OEBPS", "Text" ))
        end
      end
    end
  end
end
