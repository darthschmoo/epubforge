module EpubForge
  module Action
    class ActionsLookup
      attr_accessor :actions, :actions_directories, :keywords

      def initialize
        clear
      end

      def clear
        @keywords = {}
        @actions = []
        @actions_directories = [] 
      end
      
      def add_actions( *args )
        Utils::ActionLoader.load_me( *args )

        new_actions = Utils::ActionLoader.loaded_classes - @actions
        @actions += new_actions
        new_directories = Utils::ActionLoader.loaded_directories - @actions_directories
        @actions_directories += new_directories

        for action in new_actions
          for keyword in action.keywords
            @keywords[keyword] = action
          end
        end
      end

      # Find all the actions with keywords that start with the given string.
      # If this results in more than one action being found, the proper
      # response is to panic and flail arms.
      def keyword_to_action( keyword )
        exact_match = @keywords.keys.select{ |k| k == keyword }

        return [@keywords[exact_match.first]] if exact_match.length == 1

        # if no exact match can be found, find a partial match, at the beginning
        # of the keywords.
        @keywords.keys.select{ |k| k.match(/^#{keyword}/) }.map{ |k| @keywords[k] }.uniq
      end
    end
  end
end