module EpubForge
  module Action
    class Kindle < AbstractAction
      description "Create a .mobi book and try to push it to your Kindle"
      keywords    :kindle, :push, :b2k
      usage       "#{$PROGRAM_NAME} b2k <project_directory>"
      
      def do( project, args )
        @project = project
        BookToEpub.new.do( @project )
        
        if mobify( @project.filename_for_epub_book, @project.filename_for_mobi_book )
          puts "Formatted for Kindle (.mobi file)"
          push_to_device @project.filename_for_mobi_book
        end
      end
      
      def mobify src_epub, target_mobi
        puts "converting from #{src_epub} to #{target_mobi}"
        if File.exist?( src_epub )
          cmd = "ebook-convert #{src_epub} #{target_mobi}"
          puts "executing: #{cmd}"
          puts `#{cmd}`
          true
        else
          puts "Cannot find source .epub #{src_epub}"
          false
        end
      end
      
      def push_to_device target_mobi
        if File.exist?( File.join( "/Volumes", "Kindle" ) )
          FileUtils.copy( target_mobi, File.join( "/Volumes", "Kindle", "documents", "fic-mine") )
          puts "installed on Kindle"
        else
          puts "NOT installed on Kindle.  It may not be plugged in."
        end   
      end
    end
  end
end