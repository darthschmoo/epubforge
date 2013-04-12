require 'helper'

class TestCustomHelpers < Test::Unit::TestCase  # 
  context "Testing collect_stdout" do
    should "not print out" do
      outer = ""
      inner = ""
      
      outer = EpubForge.collect_stdout do
        puts "Hello"
          inner = EpubForge.collect_stdout do
            puts "Well this is awkward"
          end
        puts "world!"
      end
      
      assert_equal "Hello\nworld!\n", outer, "collect_stdout not working properly"
      assert_equal "Well this is awkward\n", inner, "collect_stdout not working properly"
      puts "============= STDOUT printing again =============="
    end
  end
end