require 'helper'

class TestCustomHelpers < Test::Unit::TestCase  # 
  context "Testing collect_stdout" do
    should "not print out" do
      out = collect_stdout do
        puts "Hello"
        puts "world!"
      end
      
      assert_equal "Hello\nworld!\n", out
    end
  end
end