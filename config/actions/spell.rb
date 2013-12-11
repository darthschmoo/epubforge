module EpubForge
  module Action
    class SpellDefinition
      attr_accessor :incorrect, :correct, :regex, :exact, :hits
      def initialize( incorrect, correct, opts = nil )
        @incorrect = incorrect
        @correct = correct
        @opts = opts
        @hits = 0
        
        @exact = !!(@opts =~ /x/)
        if @exact
          @regex = /(\W|^)#{@incorrect}(\W|$)/
        else
          @regex =   /#{@incorrect}/i
        end
      end
      
      def hit
        @hits += 1
      end
    end
    
    class Spell < ThorAction
      SPELL_CORRECTION_FILE = "spellings"
      
      description "Highlight possible misspellings, as defined by the settings file /#{SPELL_CORRECTION_FILE}."
      keywords    :spell
      usage       "#{$PROGRAM_NAME} spell <project_directory>"
      
      desc( "do:spell", "replace common misspellings." )
      
      def do( project, *args )
        @project = project
        @spellings_file = @project.settings_folder( SPELL_CORRECTION_FILE )
        
        load_spellings
        
        @auto = args.include?("--auto")
        
        for file in @project.pages
          puts "\n#{file}"
          puts "=" * file.to_s.length

          file.readlines.each_with_index do |line, i|
            for spelling in @spellings
              if m = line.match( spelling.regex )
                spelling.hit
                puts "#{i}: #{spelling.incorrect} ==> #{spelling.correct} - #{line.gsub(spelling.regex, "<<<<#{spelling.incorrect}>>>>>")}"
              end
            end
          end
        end
        
        
        hit_report
      end
      
      protected
      def load_spellings
        quit_with_error( "File does not exist: #{@spellings_file}") unless @spellings_file.file?
        @spellings = []
        for line in @spellings_file.readlines
          next if line =~ /^\s*(#|$)/                    # remove comments and blank lines
          chunks = line.split("|").map(&:strip)
          @spellings << SpellDefinition.new( *chunks )
        end
        
        puts @spellings.inspect
      end
      
      def hit_report
        for spelling in @spellings.select{|spell| spell.hit > 0}.sort_by(&:hits)
          puts "#{spelling.incorrect} ===> #{spelling.correct} (#{spelling.hits})"
        end
      end
    end
  end
end