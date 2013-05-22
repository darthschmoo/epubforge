module EpubForge
  module Action
    class Kindle < ThorAction
      description "Create a .mobi book and try to push it to your Kindle (conversion requires Calibre)"
      keywords    :kindle, :push, :b2k
      usage       "#{$PROGRAM_NAME} b2k <project_directory>"
      # requires_executable "ebook-convert"
      
      # TODO:  Hard-coded.  Need a global settings file?
      KINDLE_DEVICE_DIR = "/".fwf_filepath.join( "Volumes", "Kindle" )
      KINDLE_PUSH_DIR   = KINDLE_DEVICE_DIR.join("documents", "fic-mine")
      
      desc( "do:kindle", "Turn your .epub file into a .mobi file.  Check to see if your Kindle is connected, then pushes it." )
      def do( project, *args )
        @project = project
        @src_epub = @project.filename_for_epub_book.fwf_filepath
        @dst_mobi = @project.filename_for_mobi_book.fwf_filepath

      end
      
      protected
      def mobify
        return false unless fulfill_requirements
        
        say "converting from #{@src_epub} to #{@dst_mobi}"
        cmd = "ebook-convert #{@src_epub} #{@dst_mobi}"
        say "executing: #{cmd}"
        `#{cmd}`

        if $?.success? && @dst_mobi.exist?
          say_all_is_well "Formatted for Kindle (.mobi file).  File at #{@dst_mobi}."
          push_to_device @dst_mobi
        else
          warn( "Something went wrong during the conversion process." )
          warn( "#{@dst_mobi} exists, but may not be complete or correct." ) if @dst_mobi.exist?  
          false
        end
      end
      
      def push_to_device mobi_file
        if KINDLE_DEVICE_DIR.directory? && KINDLE_PUSH_DIR.directory?
          FileUtils.copy( mobi_file, KINDLE_PUSH_DIR )
          say_all_is_well "File pushed to Kindle."
          true
        else
          say_error "NOT installed on Kindle.  It may not be plugged in."
          false
        end   
      end
      
      def fulfill_requirements
        unless ebook_convert_installed?
          say_error( "ebook-convert is not installed.  Quitting." )
          return false 
        end
        
        BookToEpub.new.do( @project )
        
        unless @src_epub.exist?
          say_error( "Cannot find source .epub #{src_epub}" )
          return false
        end

        true
      end
    end
  end
end