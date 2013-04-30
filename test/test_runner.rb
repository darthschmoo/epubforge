require 'helper'

Runner = EpubForge::Action::Runner

class TestRunner < Test::Unit::TestCase  
  context "Testing argument parsing" do
    setup do
      @runner = Runner.new
    end
    
    should "parse empty args" do
      # @runner.send( :parse_args, ???  )
    end
  end
end