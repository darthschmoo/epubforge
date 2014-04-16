module EpubForge
  module Utils
    class Misc
      # stolen from Rails constantize method, via StackOverflow
      # http://stackoverflow.com/questions/3314475/how-do-i-get-class-object-from-string-abc-in-ruby
      def self.constantize( str )
        names = str.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        
        constant
      end
    end
  end
end