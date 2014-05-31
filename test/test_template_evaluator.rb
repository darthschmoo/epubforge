require 'helper'

class TestBookTemplates < EpubForge::TestCase
  context "testing default templates" do
    setup do
      @template_dir = EpubForge.root( "templates", "project" )
    end
    
    should "properly create files from default templates" do
      tempdir do
        assert @template_dir.directory?
        assert @tmpdir.directory?
      
        src = @template_dir.join( "book", "afterword.markdown" )
        dest = @tmpdir.join( "afterword.markdown" )
        FunWith::Templates::TemplateEvaluator.write( src, dest )

        assert_file_has_content dest
        assert_file_contents dest, /all the way/
        assert_file_contents dest, /go find something else to do/
          
        src = @template_dir.join( "book", "cover.xhtml.template" )
        dest = @tmpdir.join( "cover.xhtml" )
        FunWith::Templates::TemplateEvaluator.write( src, dest, fill_in_project_options[:answers] )
      
        assert dest.file?
        src = @template_dir.join( "notes", "character.%character.name_for_file%.markdown.template" )
        
        # specifying only the directory to write the file into should nonetheless yield the proper behavior
        dest = @tmpdir   
        vars = { :character => {:name => "Wilber Pontiff", :name_for_file => "wilber_pontiff"}}
        
        FunWith::Templates::TemplateEvaluator.write( src, @tmpdir, vars )
      
        dest = dest.join("character.wilber_pontiff.markdown")
        assert_file_has_content dest
        assert_file_contents( dest, /Wilber Pontiff/ )
        assert_file_contents( dest, /^==============$/ )
      end
    end
  end
end