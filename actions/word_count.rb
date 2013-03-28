require 'time'  # for Time.parse

module EpubForge
  module Action
    class WordCount < AbstractAction
      WORD_COUNT_FILE = ".word_count.epubforge"
      
      description "Gives approximate word counts for book chapters and notes."
      keywords    :wc, :count
      usage       "#{$PROGRAM_NAME} count <project_directory>"
      
      def wc_one_folder( foldername )
        count = 0
        EpubForge::Epub::Builder::PAGE_FILE_EXTENSIONS.each{ |ext|
          files = foldername.glob("*.#{ext}")
          for file in files
            result = `wc -w #{file}`
            count += $?.success? ? result.to_i : 0  
          end      
        }
        count
      end
      
      def load_word_count_history
        @wc_yaml = File.join( @project.target_dir, WORD_COUNT_FILE )
        File.touch( @wc_yaml )
        @history = YAML.load( File.read( @wc_yaml ) ).epf
        
        @first_time_running = @history == false    # false is what you get when you YAML.load a blank file
      end
      
      def append_word_count_history( timestamp = Time.now )
        if @report["Today"] == 0 && !@first_time_running
          return false
        end
        
        File.open( @wc_yaml, "a" ) do |f|
          f.write "- #{timestamp}:\n"
          f.write "    Notes: #{@report["Notes"]}\n"
          f.write "    Book:  #{@report["Book"]}\n\n"
        end
      end
      
      
      # Works under the ginormous assumption that the last word count recorded for the previous
      # day was actually the final count, and every word written since then was written for the
      # current day.  When running for the first time, assumes all prior work was completed the
      # previous day, and falsifies a history to match that assumption.
      def calculate_todays_word_count
        @now = Time.now
        @beginning_of_day = Time.parse( @now.strftime("%Y-%m-%d") )
        
        if @first_time_running  # then fake data
          @history = [{@now => {"Notes" => 0, "Book" => 0}}].epf
          append_word_count_history( @beginning_of_day - 1 )
          @report["Today"] = 0
        else
          while !(@history.blank?) && Time.parse( @history.last.keys.first ) > @beginning_of_day
            @history.pop
          end

          @current = @history.last.values.first
          
          @report["Today"] = @report["Notes"] + @report["Book"] - @current["Notes"] - @current["Book"]
        end 
      end
      
      def print_report
        puts ""
        puts "Wordcount"
        puts "---------"
        puts "Notes: #{@report["Notes"]}"
        puts "Book:  #{@report["Book"]}"
        puts "Today: #{@report["Today"]}"
      end
      
      def do( project, args = [] )
        @project = project
        @report  = {}

        @report["Notes"] = wc_one_folder( @project.notes_dir )
        @report["Book"]  = wc_one_folder( @project.book_dir )
        load_word_count_history
        calculate_todays_word_count
        append_word_count_history
        print_report
        
        puts "Done"
      end
    end
  end
end