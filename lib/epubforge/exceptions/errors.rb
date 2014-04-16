module EpubForge
  module Exceptions
    class NotAProject < Exception; end
    class FileError < Exception; end
    class FileDoesNotExist < FileError; end
    class FileMustNotExist < FileError; end
  end
end