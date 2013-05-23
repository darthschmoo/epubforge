module EpubForge
  module Action
    class Mobify < ThorAction
      description "Create a .mobi book and try to push it to your Kindle (conversion requires Calibre)"
      keywords    :mobify
      usage       "#{$PROGRAM_NAME} mobify <project_directory(optional)>"
      # requires_executable "ebook-convert", "ebook-convert is included as part of the Calibre ebook management software."
      
      desc( "do:mobify", "Turn your .epub file into a .mobi file." )
      def do( project, *args )
        @project = project
        @src_epub = @project.filename_for_epub_book.fwf_filepath
        @dst_mobi = @project.filename_for_mobi_book.fwf_filepath
        
        @args = args
        @regenerate_epub = !!( @args.include?( "--no-cache" ) )
        
        mobify
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
        else
          warn( "Something went wrong during the conversion process." )
          warn( "#{@dst_mobi} exists, but may not be complete or correct." ) if @dst_mobi.exist?  
          false
        end
      end

      
      def fulfill_requirements
        unless ebook_convert_installed?
          say_error( "ebook-convert is not installed.  Quitting." )
          return false 
        end
        
        if !@src_epub.exist? || @regenerate_epub
          BookToEpub.new.do( @project ) 
        end
        
        unless @src_epub.exist?
          say_error( "Cannot find source .epub #{src_epub}" )
          return false
        end

        true
      end
    end
  end
end