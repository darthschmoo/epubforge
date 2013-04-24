class String
  TITLE_WORDS_NOT_CAPITALIZED = %W(a an in the for and nor but or yet so also)
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