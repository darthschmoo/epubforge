module EpubForge
  module Action
    class Help < AbstractAction
      description "The help menu."
      keywords    :help, :"-h", :"--help"
      usage       "#{$PROGRAM_NAME} -h"
      project_not_required
      
      def do( project, *args )
        puts "epubforge [action] [folder]"
        puts "\tActions:"
        for action in Action::Runner.instance.actions
          puts "\t\t( #{action.keywords.join(" | ")} ) :"
          puts "\t\t\tDescription: #{action.description}"
          puts "\t\t\tUsage:       #{action.usage}"
        end
      end
    end
  end
end
