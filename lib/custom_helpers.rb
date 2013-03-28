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
