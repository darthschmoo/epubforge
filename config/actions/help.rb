module EpubForge
  module Action
    class Help < Action2
      define_action( "help" ) do |action|
        action.project_not_required
        action.help( "Print out information for various actions." )

        action.execute do
          say_instruction "Actions:"
          for keyword, action in Action2.loader_pattern_registry
            say_instruction "  #{keyword} : #{action.help}"
            say_instruction "     usage: #{$PROGRAM_NAME} #{action.keyword} #{action.usage}" unless action.usage.fwf_blank?
          end
        end
      end
    end
  end
end
