class EpubForge::String < String
  def camelize
    gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  def blank?
    strip.length == 0
  end

  # TODO: Need comprehensive list of characters to be protected.
  def backhashed_filename
    self.gsub(" ", "\\ ")  
  end
end

class String
  def epf
    EpubForge::String.new(self)
  end
  
  def epf_filepath
    EpubForge::Utils::FilePath.new(self)
  end
  
  def to_pathname
    Pathname.new( self )
  end
end