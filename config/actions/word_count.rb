require 'time'  # for Time.parse

module EpubForge
  module Action
    class WordCount < Action2
      # include_standard_options
      
      WORD_COUNT_FILE = "wordcount"
      
      define_action( "wc" ) do |action|
        action.help( "Manage your word counts for book chapters and notes.  wc (standalone) is main command" )
        
      # keywords    :wc
      #       usage       "#{$PROGRAM_NAME} count <project_directory>"
      #       
      # desc( "wc", "Countify words.")
        action.execute do
          @report  = { "Notes" => wc_one_folder( @project.notes_dir ),
                       "Book"  => wc_one_folder( @project.book_dir  ) }

          load_word_count_history
          calculate_todays_word_count
          append_word_count_history( @report )
          print_report
        
          say_all_is_well( "Done" )
          @report
        end
      end
      
      protected
      def wc_one_folder( foldername )
        foldername.glob( ext: EpubForge::Builder::PAGE_FILE_EXTENSIONS ).inject(0) do |count, file|
          count += wc_one_file( file )
        end
      end
      
      # I assume the wc executable is more accurate,
      # and I don't know which is faster.
      def wc_one_file( filename )
        if wc_installed?
          result = `#{wc_installed?.to_s.strip} -w #{filename}`
          $?.success? ? result.to_i : 0
        else
          filename.read.split.length
        end
      end
      
      def load_word_count_history
        @wc_yaml = @project.settings_folder( WORD_COUNT_FILE )
        @wc_yaml.touch
        
        if @wc_yaml.empty?
          # pretend that you wrote everything in the last six hours.
          append_word_count_history( {"Notes" => 0, "Book" => 0}, beginning_of_day )
        end
        
        @history = YAML.load( @wc_yaml.read )
      end
      
      def beginning_of_day
        @beginning_of_day ||= Time.parse( now.strftime("%Y-%m-%d") )
        @beginning_of_day
      end
      
      def now
        @now ||= Time.now
        @now
      end
      
      def append_word_count_history( report, timestamp = now )
        unless duplicates_previous_history_item( report )
          @wc_yaml.append do |f|
            f.write "- #{timestamp}:\n"
            f.write "    Notes: #{report["Notes"]}\n"
            f.write "    Book:  #{report["Book"]}\n\n"
          end
        end
      end
      
      def duplicates_previous_history_item( report )
        last = @history.last
        prior_report = last.values.last
        time_of_history_item( last ) > beginning_of_day && 
          prior_report["Notes"] == report["Notes"] && 
          prior_report["Book"] == report["Book"]
      end
      
      # Works under the ginormous assumption that the last word count recorded for the previous
      # day was actually the final count, and every word written since then was written for the
      # current day.  When running for the first time, assumes all prior work was completed the
      # previous day, and falsifies a history to match that assumption.
      def calculate_todays_word_count
        prior_day = @history.reverse.find do |history_item|
          time_of_history_item( history_item ) <= beginning_of_day
        end
        
        # This should never be nil, but...
        prior_day = prior_day.nil? ? { "Book" => 0, "Notes" => 0 } : prior_day.values.first
        
        @report["Today"] = @report["Notes"] + @report["Book"] - prior_day["Notes"] - prior_day["Book"]
      end
      
      def time_of_history_item( item )
        t = item.keys.first
        t = case( t )
        when Time
          t
        when String
          Time.parse( t )
        else
          raise "I have no idea what time it is."
        end
      end
      
      def wc_installed?
        executable_installed?( "wc" )
      end
      
      def print_report
        say( "\nWordcount", :blue )
        say( "---------", :blue )
        say( "Notes: #{@report["Notes"]}", :blue )
        say( "Book:  #{@report["Book"]}", :blue )
        say( "Today: #{@report["Today"]}", :blue )
      end
    end
  end
end