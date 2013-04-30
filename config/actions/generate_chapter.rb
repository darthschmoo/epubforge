module EpubForge
  module Action
    class GenerateChapter < Generate
      # examples:
      #
      #   epubforge new chapter        # adds a new chapter to the end of the book
      #   epubforge new chapter +5     # adds five new chapters to the end of the book
      #   epubforge new chapter 13     # Replaces 13 with a blank chapter, moving the old 13 to 14, the old 14 to 15, etc.
      #   epubforge new chapter 13+5   # Creates new chapter 13, 14, 15, 16, 17.  Subsequent chapters get a +5
      #   I don't believe that more complex expressions are desirable.
      desc( "do:new:chapter", "Add chapters to book" )
      def do( project, *args )
        expr = args.shift
        
        puts expr
        puts project.chapters
        
      end
      
      protected
      def chapter( project, args )
        GenerateChapter.new.do( project, *args )
      end
    end
  end
end