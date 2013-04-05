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
  
  def epf_filepath
    EpubForge::Utils::FilePath.new(self)
  end
  
  def to_pathname
    Pathname.new( self )
  end
end