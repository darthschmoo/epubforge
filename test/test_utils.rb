require 'helper'

include EpubForge::Utils

class TestUtils < Test::Unit::TestCase
  context "testing file orderer" do
    should "accurately sort files in the templates/book dir" do
      files = EpubForge.root.join( "templates", "default", "book" ).glob( :ext => "markdown" )
      reordered_files = FileOrderer.new( %w(title_page foreword chapter.* afterword) ).reorder(files).map(&:to_s)

      assert_match /title.*markdown/, reordered_files.first.to_s
      assert_match /chap.*02.*markdown/, reordered_files[-2].to_s
      assert_match /afterword\.markdown/, reordered_files.last.to_s
      
    end
  end
  
  context "testing template_handler" do
    should "evaluate erb in a string" do
      sample = "(<%= Time.now %>): <%= @var_is_set %>"
      result = TemplateEvaluator.new( sample, var_is_set: "true" ).result
      
      assert_match /true/, result
      time_string = /\((.*)\)/.match(result)[1]
      assert_kind_of Time, Time.parse( time_string )
    end
  end
end
