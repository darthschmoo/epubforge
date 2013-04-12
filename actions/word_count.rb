require 'time'  # for Time.parse

module EpubForge
  module Action
    class WordCount < AbstractAction
      WORD_COUNT_FILE = "wordcount"
      
      description "Gives approximate word counts for book chapters and notes."
      keywords    :wc, :count
      usage       "#{$PROGRAM_NAME} count <project_directory>"
      
      def wc_one_folder( foldername )
        count = 0
        for file in foldername.glob( ext: EpubForge::Epub::PAGE_FILE_EXTENSIONS )
          count += wc_one_file( file )
        end      
        
        count
      end
      
      # I assume the wc executable is more accurate,
      # and I don't know which is faster.
      def wc_one_file( filename )
        if wc_available
          result = `#{wc_available} -w #{filename}`
          $?.success? ? result.to_i : 0
        else
          filename.read.split.length
        end
      end
      
      def load_word_count_history
        @wc_yaml = @project.settings_folder( WORD_COUNT_FILE ).touch
        
        if @wc_yaml.empty?
          # pretend that you wrote everything in the last six hours.
          append_word_count_history( {"Notes" => 0, "Book" => 0}, Time.parse( Time.now.strftime("%Y-%m-%d") ) )
        end
        
        @history = YAML.load( @wc_yaml.read )
      end
      
      def append_word_count_history( report, timestamp = Time.now )
        @wc_yaml.append do |f|
          f.write "- #{timestamp}:\n"
          f.write "    Notes: #{report["Notes"]}\n"
          f.write "    Book:  #{report["Book"]}\n\n"
        end
      end
      
      
      # Works under the ginormous assumption that the last word count recorded for the previous
      # day was actually the final count, and every word written since then was written for the
      # current day.  When running for the first time, assumes all prior work was completed the
      # previous day, and falsifies a history to match that assumption.
      def calculate_todays_word_count
        @now = Time.now
        @beginning_of_day = Time.parse( @now.strftime("%Y-%m-%d") )
        while !(@history.epf_blank?) && Time.parse( @history.last.keys.first ) > @beginning_of_day
          @history.pop
        end

        @current = @history.last.values.first
        
        @report["Today"] = @report["Notes"] + @report["Book"] - @current["Notes"] - @current["Book"]
      end
      
      def wc_available
        if @wc_exec.nil?
          which_wc = `which wc`.strip
          if which_wc.epf_blank?
            @wc_exec = false
          else
            @wc_exec = which_wc.epf_filepath
          end
        end
        
        @wc_exec
      end
      
      def print_report
        puts ""
        puts "Wordcount"
        puts "---------"
        puts "Notes: #{@report["Notes"]}"
        puts "Book:  #{@report["Book"]}"
        puts "Today: #{@report["Today"]}"
      end
      
      def do( project, *args )
        @project = project
        @report  = {}
        
        @report["Notes"] = wc_one_folder( @project.notes_dir )
        @report["Book"]  = wc_one_folder( @project.book_dir )
        load_word_count_history
        calculate_todays_word_count
        append_word_count_history( @report )
        print_report
        
        puts "Done"
        @report
      end
    end
  end
end