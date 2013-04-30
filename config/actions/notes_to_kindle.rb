module EpubForge
  module Action
    class NotesToKindle < Kindle
      description "Create a .mobi book from the notes and try to push it to your Kindle"
      keywords    :n2k
      usage       "#{$PROGRAM_NAME} n2k <project_directory>"
  
      def do( project, args )
        @project = project
        @src_epub = @project.filename_for_epub_notes.fwf_filepath
        @dst_mobi = @project.filename_for_mobi_notes.fwf_filepath

        mobify
      end
    end
  end
end