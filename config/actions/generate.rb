module EpubForge
  module Action
    class Generate < ThorAction
      keywords  :new, :generate, :add
      description "Add something to the project (a new chapter, or a new wiki entry, etc.)"
    
      desc( "do:new:XXXXXXX", self.description )
      def do( project, *args )
        case @new_what = args.shift
        when "chapter"
          chapter( project, args )
        else
          puts "Unrecognized generator #{@new_what}.  Quitting."
          exit(0)
        end
      end
      
      protected
      def chapter( project, args )
        GenerateChapter.new.do( project, *args )
      end
    end
  end
end