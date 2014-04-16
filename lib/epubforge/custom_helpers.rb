module EpubForge
  module CustomHelpers
    def ask question, opts = {}
      opts[:menu] ||= [["Y", "Yes"], ["N", "No"]]

      answer = nil

      while answer.nil?
        menu_string = opts[:menu].map{ |li| "#{li[0]}):\t#{li[1]}"}.join("\n\t")
        puts "#{question} :\n\t#{ menu_string }"
        line = Readline.readline(">> ",true).strip.upcase

        opts[:menu].each{ |li|
          if li[0].upcase == line.to_s
            answer = li
          end
        }
    
        puts "I don't understand that response" if answer.nil?
      end

      if opts[:return_value]
        answer[1]
      else
        answer[0].upcase
      end
    end

    # To see the STDOUT, simply call EpubForge.collect_stdout( STDOUT )
    def collect_stdout( dest = StringIO.new, &block )
      if dest == $stdout
        yield
      else
        raise ArgumentError.new("No block given.") unless block_given?
      
        prior_stdout = $stdout
        # @epf_prior_stdout_stack ||= []
        # @epf_prior_stdout_stack << $stdout
       
        $stdout = begin
                    if dest.is_a?( String ) || dest.is_a?( Pathname )
                      File.open( dest, "a" )
                    elsif dest.is_a?( IO ) || dest.is_a?( StringIO )
                      dest
                    else
                      raise ArgumentError.new("collect_stdout cannot take a <#{dest.class.name}> as an argument.")
                    end
                  end
    
        $stdout.sync = true
        yield
    
        $stdout = prior_stdout
      
        dest.is_a?( StringIO ) ? dest.string : nil
      end
    end
    
    # def collect_stdout( *args, &block )
    #   yield
    #   ""
    # end
  end
end

