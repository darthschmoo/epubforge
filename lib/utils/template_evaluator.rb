module EpubForge
  module Utils
    class TemplateEvaluator
      attr_reader :content, :vars, :result
      def initialize( content, vars = {} )
        if content.is_a?(Pathname) && content.file?
          @content = @content.read
        else
          @content = content.to_s
        end
        
        @vars = vars
        
        @result = with_locals(@vars) do
          ERB.new( @content ).result( binding )
        end
      end
    end
  end
end