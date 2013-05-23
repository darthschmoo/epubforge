class String
  def epf_blank?
    self.strip.length == 0  
  end
  
  def epf_camelize
    gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  # TODO: Need comprehensive list of characters to be protected.
  def epf_backhashed_filename
    self.gsub(" ", "\\ ")  
  end
  
  def epf_titlecap_words
    nocaps = %w(a and at be but in is nor of or so teh the to with)
    upcase = %w(Ii Ii: Iii M.d.)       # TODO:  ick

    words = self.downcase.gsub(/\u00a0/, ' ').split(/(\s|\n)+/).map(&:strip).delete_if(&:epf_blank?)
    first_word = true

    for word in words
      word.capitalize! unless nocaps.include?(word) && first_word == false    # note: if the word is all caps, will downcase  # TODO: What about M.D., state abbreviations, etc.?  This is far from perfect.
      word.upcase! if upcase.include?(word)
      first_word = false
    end
    
    words.join(" ")
  end
  
  def epf_underscorize
    self.downcase.gsub(/\s+/,"_").gsub(/[\W]/,"")
  end
  
  # def fwf_filepath
  #   EpubForge::FunWith::Files::FilePath.new(self)
  # end
  
  def to_pathname
    Pathname.new( self )
  end
  
  def epf_deunderscorize_as_title
    words = self.split("_")
    
    words = [words[0].capitalize] + words[1..-1].map{|w| 
      TITLE_WORDS_NOT_CAPITALIZED.include?(w) ? w : w.capitalize
    }
    
    words.join(" ")
  end
end