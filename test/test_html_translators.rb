require 'helper'

class TestHtmlTranslators < EpubForge::TestCase
  context "testing htmlizers" do
    setup do
      @translator_class = EpubForge::Utils::HtmlTranslator
      @samples = EpubForge.root("test", "sample_text")
    end
    
    should "test markdown" do
      result = @translator_class.translate( @samples.join("sample.markdown") )
      assert_match /<h1.*This is a header</, result
    end
    
    should "test textile" do
      result = @translator_class.translate( @samples.join("sample.textile") )
      assert_match /<h1.*This is a header</, result
    end
  end
end