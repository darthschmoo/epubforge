module EpubForge
  module Action
    class Help < ThorAction
      description "The help menu."
      keywords    :help, :"-h", :"--help"
      usage       "#{$PROGRAM_NAME} -h"
      project_not_required
      
      desc( "do:help", "print out help for the various actions.")
      def do( project, *args )
        say_instruction "epubforge [action] [folder]"
        say_instruction "\tActions:"
        for action in Action::Runner.instance.actions
          say_instruction "\t( #{action.keywords.join(" | ")} ) :"
          say_instruction "\t\tDescription: #{action.description}"
          say_instruction "\t\tUsage:       #{action.usage}\n"
        end
      end
    end
  end
end
