require 'helper'

include EpubForge::Utils

class TestUtils < EpubForge::TestCase
  context "testing file orderer" do
    should "accurately sort files in the templates/book dir" do
      files = %W(afterword.markdown 
                 chapter-0002.markdown 
                 chapter-0001.markdown 
                 foreword.markdown 
                 title_page.markdown 
                 chapter-0003.markdown)
                 
      files_in_expected_order = %W( title_page.markdown 
                                    foreword.markdown 
                                    chapter-0001.markdown 
                                    chapter-0002.markdown 
                                    chapter-0003.markdown 
                                    afterword.markdown)
                                    
      orderers = %w(title_page foreword chapter-.* afterword)
      reordered_files = FileOrderer.new( orderers ).reorder( files ).map(&:to_s)

      assert_equal files_in_expected_order, reordered_files
    end
  end
end
