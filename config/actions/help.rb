module EpubForge
  module Action
    class Help < ThorAction
      project_not_required
      
      desc( "help", "print out help for the various actions.")
      def help( *args )
        say_instruction "epubforge [action] [folder]"
        say_instruction "\tActions:"
        say_instruction ThorAction.command_to_action_classes.inspect
        # for action in ThorAction.c
        #   say_instruction "\t( #{action.keywords.join(" | ")} ) :"
        #   say_instruction "\t\tDescription: #{action.description}"
        #   say_instruction "\t\tUsage:       #{action.usage}\n"
        # end
      end
    end
  end
end
