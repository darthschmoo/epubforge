module EpubForge
  module Action
    module Chatterbox
      def say( message, color = nil )
        puts message.paint(color)
      end
      
      def ask( question, opts = {} )
        while true
          opts[:colors] ||= opts[:color]
          
          answer = nil
          input = Readline.readline( question.paint(opts[:colors] ) + " " ).strip
          input.strip
          
          if input.fwf_blank?
            if opts[:default]
              answer = opts[:default]
            elsif opts[:blank_allowed] || (opts[:possible_answers] || []).include?("")
              answer = input
            end
          elsif opts[:possible_answers]
            answer = input if opts[:possible_answers].include?( input )
          else
            answer = input
          end
          
          if answer.nil?
            say( "'#{input}' is not a valid answer.", :red )
            say( "Possible answers: #{ opts[:possible_answers].inspect }") if opts[:possible_answers]
          end
          
          return answer unless answer.nil?
        end
      end
      
      def yes?( message, opts = {} )
        opts[:colors]   ||= :blue
        opts[:possible_answers] = ["Y", "y", "N", "n", "yes", "no"]
        opts[:default] ||= "y"
        
        answer = ask( "#{message} (Y/n)", opts ).downcase[0..1]
        
        answer == "y"
      end
      
      def yes_prettily?( statement )
        yes?( statement, :color => :pink )
      end
      
      
      def no?( message, color = nil )
        opts[:allowed] = ["Y", "y", "N", "n"]
        opts[:default] = "n"
        answer = ask( "#{message} (y/N)", opts ).downcase
        
        answer == "n"
      end
      
      def say_instruction( instruction )
        puts instruction.paint(:yellow)
      end
      

      def ask_from_menu( statement, choices )
        choices.map! do |choice|
          choice.is_a?(String) ? [choice] : choice    # I'm being too clever by half here.  .first/.last still works.
        end
        
        choice_text = ""
        choices.each_with_index do |choice,i|
          choice_text << "\t\t#{i}) #{choice.first}\n" 
        end
        
        selection = ask( "#{statement}\n\tChoices:\n#{choice_text}>>> ".paint(:blue) )
        choices[selection.to_i].last
      end
      
      def ask_prettily( question, *args )
        ask( question.paint(:blue), *args  )
      end
      
      def say_all_is_well( statement )
        say( statement, :green )
      end
      
      def say_error( statement )
        say( statement.paint(:bg_red, :bold) )
      end
      
    end
  end
end