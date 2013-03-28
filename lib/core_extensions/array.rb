class EpubForge::Array < Array
  def blank?
    length == 0
  end
end

class Array
  def epf
    EpubForge::Array.new(self)
  end
end
