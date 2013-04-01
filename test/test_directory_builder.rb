require 'helper'

DirBuilder = EpubForge::Utils::DirectoryBuilder

class TestDirectoryBuilder < Test::Unit::TestCase
  # def test_should_rename_files_on_copy
  #   d = DirBuilder.new( EpubForge.root )
  #   assert_kind_of DirBuilder, d
  #   
  #   DirBuilder.tmpdir do |b|
  #     assert_equal DirBuilder, b.class
  #     arr = [ EpubForge.root.join("lib", "custom_helpers.rb"), "helpers.rb" ] # rename dest 
  #     assert_kind_of Array, arr
  #     assert arr.is_a?(Array)
  # 
  #     b.copy arr
  #   end
  # end  
  
  context "tearing my hair out because shoulda seems borked" do
    should "stop blaming shoulda for my problems" do
      assert true
    end
  
    should "realize that assert statements need to be inside should blocks" do
      assert "Okay, okay.  I get it.  Now lay off me."
    end
  
    should "figure out why the hell [].is_a?(Array) returns false" do
      assert_kind_of Array, []
      assert [].is_a?(Array)
      # seems fine here.
      # subclassing Array for use in the EpubForge module seems
      # to be the culprit.  Guess I'm not doing that.
    end
  end
  
  context "In a temporary directory" do
    should "create a temporary directory" do
      DirBuilder.tmpdir do |b|
        assert_equal DirBuilder, b.class    # 
        assert b.current_path.exist?
      end
    end
  
    should "write data to a new file" do
      DirBuilder.tmpdir do |b|
        assert_equal DirBuilder, b.class    # Okay, WTF does this test fail?
        assert b.current_path
        assert b.current_path.exist?
        b.file("widdershins.txt") do |f|
          f << "Hello World"
          f.flush
        
          assert b.current_file.exist?
          assert_equal 11, b.current_file.size
        end
      end
    end
  
    should "copy files from elsewhere into the directory" do
      DirBuilder.tmpdir do |b|
        assert_equal DirBuilder, b.class
        src = EpubForge.root.join("Gemfile")
        assert src.exist?
      
        b.copy( EpubForge.root.join("Gemfile") )
          
        gemfile = b.current_path.join("Gemfile")
        assert gemfile.exist?
        assert !gemfile.zero?
        assert_equal 1, gemfile.grep( /jeweler/ ).length
      end
    end
  
    should "copy files from elsewhere, renaming the file in the destination" do
      DirBuilder.tmpdir do |b|
        assert_equal DirBuilder, b.class
        arr = [ EpubForge.root.join("lib", "custom_helpers.rb"), "helpers.rb" ] # rename dest 
        assert_kind_of Array, arr
        assert arr.is_a?(Array)
  
        b.copy arr
      end
    end
    
    should "download random crap from all over the Internet" do
      DirBuilder.tmpdir do |b|
        gist_url = "https://gist.github.com/darthschmoo/5281550/raw/5b95730a7c43f1e7fd9fa33617b6447215fa8ba1/gistfile1.txt"
        gist_text = "This is a file\n==============\n\n**silent**: But _bold_! [Link](http://slashdot.org)"
        b.download( gist_url, "gist.txt" )
        
        b.file( "gist.txt.2" ) do
          b.download( gist_url )
        end
        
        assert b.current_file.nil?
        assert b.current_path.join("gist.txt").exist?
        assert b.current_path.join("gist.txt.2").exist?
        assert_equal gist_text, b.current_path.join("gist.txt").read
      end
    end
  
    should "exercise all manner of features to create a complex directory" do
      DirBuilder.tmpdir do |b|
        assert_equal DirBuilder, b.class
        root = EpubForge.root
        gemfile = root.join("Gemfile")
        b.copy( gemfile )
        assert gemfile.exist?
        assert_equal gemfile.size, b.current_path.join("Gemfile").size
        
        b.dir( "earth" ) do
          b.dir( "air") do
            b.dir( "fire" ) do
              b.dir( "water" ) do
                b.file( "hello.txt" )
                b.file << "H"
                b.file << "e"
                b.file << "l"
                b.file << "l"
                b.file << "o"
              end
              
              assert b.current_file.nil?
            end
          end
        end
        
        assert "Hello", b.current_path.join("earth", "air", "fire", "water", "hello.txt").read
        
        b.dir( "fire", "water", "earth", "air" ) do
          assert b.current_path.exist?
          b.copy %W(Gemfile Gemfile.lock Rakefile).map{ |f| EpubForge.root.join( f ) }
        end
      end
    end
  end
end
