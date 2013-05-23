module EpubForge
  module Action
    class Version < ThorAction
      description "Print version (v.#{EpubForge::VERSION}, to save you the trouble)"
      keywords    :version, :"--version"
      usage       "#{$PROGRAM_NAME} -v"
      project_not_required
      
      desc( "do:version", "print out help for the various actions.")
      def do( project, *args )
        puts "epubforge v. #{EpubForge::VERSION}, Copyright Bryce Anderson.  MIT License."
      end
    end
  end
end
