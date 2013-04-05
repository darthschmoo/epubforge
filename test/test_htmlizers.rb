require 'helper'
Htmlizer = EpubForge::Utils::Htmlizer

class TestHtmlizers < Test::Unit::TestCase
  context "testing htmlizers" do
    setup do
      @samples = EpubForge.root.join("test", "sample_text")
    end
    
    should "test markdown" do
      result = Htmlizer.htmlize( @samples.join("sample.markdown") )
      assert_match /<h1.*This is a header</, result
    end
    
    should "test textile" do
      result = Htmlizer.htmlize( @samples.join("sample.textile") )
      assert_match /<h1.*This is a header</, result
    end
    
    should "test everything else" do
      skip "not written"
    end
  end
end