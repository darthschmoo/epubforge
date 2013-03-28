class EpubForge::File < File
  def self.touch( filename )
    `touch #{filename} >> /dev/null`
    if $? != 0
      raise "File does not exist or is not writable: #{filename}"
    end
  end
end