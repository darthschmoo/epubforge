class Object
  def umethods( regex = /.*/ )
    (self.methods.sort - Object.new.methods).grep( regex )
  end
end
