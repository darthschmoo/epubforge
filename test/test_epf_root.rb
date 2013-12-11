require 'helper'

class TestDirectoryBuilder < EpubForge::TestCase
  context "testing absolute basics" do
    should "provide an accurate root" do
      assert_equal File.expand_path( File.join( File.dirname(__FILE__), ".." ) ), EpubForge.root.to_s
    end
  end
end