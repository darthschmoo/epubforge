module EpubForge
  module Action
    class Help < ThorAction
      description "The help menu."
      keywords    :help, :"-h", :"--help"
      usage       "#{$PROGRAM_NAME} -h"
      project_not_required
      
      desc( "do:help", "print out help for the various actions.")
      def do( project, *args )
        say_instruction "epubforge [action] [folder]\n"
        say_instruction "\tActions:\n"
        for action in Action::Runner.instance.actions
          say_instruction "\t\t( #{action.keywords.join(" | ")} ) :\n"
          say_instruction "\t\t\tDescription: #{action.description}\n"
          say_instruction "\t\t\tUsage:       #{action.usage}\n"
        end
      end
    end
  end
end
