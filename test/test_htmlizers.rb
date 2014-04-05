require 'helper'

class TestHtmlizers < EpubForge::TestCase
  context "testing htmlizers" do
    setup do
      @samples = EpubForge.root("test", "sample_text")
    end
    
    should "test markdown" do
      result = Htmlizer.instance.translate( @samples.join("sample.markdown") )
      assert_match /<h1.*This is a header</, result
    end
    
    should "test textile" do
      result = Htmlizer.instance.translate( @samples.join("sample.textile") )
      assert_match /<h1.*This is a header</, result
    end
  end
end